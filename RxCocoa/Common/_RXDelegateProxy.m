//
//  _RXDelegateProxy.m
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import "_RXDelegateProxy.h"
#import "_RX.h"
#import "_RXObjCRuntime.h"

@interface _RXDelegateProxy ()

@property (nonatomic, strong) id strongForwardDelegate;

@end

static NSMutableDictionary *forwardableSelectorsPerClass = nil;

@implementation _RXDelegateProxy

+(NSSet*)collectSelectorsForProtocol:(Protocol *)protocol {
    NSMutableSet *selectors = [NSMutableSet set];

    unsigned int protocolMethodCount = 0;
    struct objc_method_description *pMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &protocolMethodCount);

    for (unsigned int i = 0; i < protocolMethodCount; ++i) {
        struct objc_method_description method = pMethods[i];
        if (RX_is_method_with_description_void(method)) {
            [selectors addObject:SEL_VALUE(method.name)];
        }
    }
            
    free(pMethods);

    unsigned int numberOfBaseProtocols = 0;
    Protocol * __unsafe_unretained * pSubprotocols = protocol_copyProtocolList(protocol, &numberOfBaseProtocols);

    for (unsigned int i = 0; i < numberOfBaseProtocols; ++i) {
        [selectors unionSet:[self collectSelectorsForProtocol:pSubprotocols[i]]];
    }
    
    free(pSubprotocols);

    return selectors;
}

+(void)initialize {
    @synchronized (_RXDelegateProxy.class) {
        if (forwardableSelectorsPerClass == nil) {
            forwardableSelectorsPerClass = [[NSMutableDictionary alloc] init];
        }

        NSMutableSet *allowedSelectors = [NSMutableSet set];

#define CLASS_HIERARCHY_MAX_DEPTH 100

        NSInteger  classHierarchyDepth = 0;
        Class      targetClass         = NULL;

        for (classHierarchyDepth = 0, targetClass = self;
             classHierarchyDepth < CLASS_HIERARCHY_MAX_DEPTH && targetClass != nil;
             ++classHierarchyDepth, targetClass = class_getSuperclass(targetClass)
        ) {
            unsigned int count;
            Protocol *__unsafe_unretained *pProtocols = class_copyProtocolList(targetClass, &count);
            
            for (unsigned int i = 0; i < count; i++) {
                NSSet *selectorsForProtocol = [self collectSelectorsForProtocol:pProtocols[i]];
                [allowedSelectors unionSet:selectorsForProtocol];
            }
            
            free(pProtocols);
        }

        if (classHierarchyDepth == CLASS_HIERARCHY_MAX_DEPTH) {
            NSLog(@"Detected weird class hierarchy with depth over %d. Starting with this class -> %@", CLASS_HIERARCHY_MAX_DEPTH, self);
#if DEBUG
            abort();
#endif
        }
        
        forwardableSelectorsPerClass[CLASS_VALUE(self)] = allowedSelectors;
    }
}

-(void)interceptedSelector:(SEL)selector withArguments:(NSArray *)arguments {
    
}

-(void)_setForwardToDelegate:(id)forwardToDelegate retainDelegate:(BOOL)retainDelegate {
    __forwardToDelegate = forwardToDelegate;
    if (retainDelegate) {
        self.strongForwardDelegate = forwardToDelegate;
    }
    else {
        self.strongForwardDelegate = nil;
    }
}

-(BOOL)hasWiredImplementationForSelector:(SEL)selector {
    return [super respondsToSelector:selector];
}

-(BOOL)canRespondToSelector:(SEL)selector {
    @synchronized(_RXDelegateProxy.class) {
        NSSet *allowedMethods = forwardableSelectorsPerClass[CLASS_VALUE(self.class)];
        NSAssert(allowedMethods != nil, @"Set of allowed methods not initialized");
        return [allowedMethods containsObject:SEL_VALUE(selector)];
    }
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector]
    || [self._forwardToDelegate respondsToSelector:aSelector]
    || [self canRespondToSelector:aSelector];
}

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    if (RX_is_method_signature_void(anInvocation.methodSignature)) {
        NSArray *arguments = RX_extract_arguments(anInvocation);
        [self interceptedSelector:anInvocation.selector withArguments:arguments];
    }
    
    if (self._forwardToDelegate && [self._forwardToDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self._forwardToDelegate];
    }
}

-(void)dealloc {
}

@end
