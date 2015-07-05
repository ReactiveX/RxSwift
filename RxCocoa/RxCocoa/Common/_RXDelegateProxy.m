//
//  _RXDelegateProxy.m
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import "_RXDelegateProxy.h"
#import <objc/runtime.h>

#define SEL_VALUE(x)    [NSValue valueWithPointer:(x)]
#define CLASS_VALUE(x)  [NSValue valueWithNonretainedObject:(x)]

// self + cmd
#define HIDDEN_ARGUMENT_COUNT   2

// inspired by https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSInvocation%2BRACTypeParsing.m
// awesome work
id RX_extract_argument_at_index(NSInvocation *invocation, NSUInteger index) {
    const char *argumentType = [invocation.methodSignature getArgumentTypeAtIndex:index];
    
#define RETURN_VALUE(type) \
    else if (strcmp(argumentType, @encode(type)) == 0) {\
        type val = 0; \
        [invocation getArgument:&val atIndex:index]; \
        return @(val); \
    }

    // Skip const type qualifier.
    if (argumentType[0] == 'r') {
        argumentType++;
    }
    
    if (strcmp(argumentType, @encode(id)) == 0
        || strcmp(argumentType, @encode(Class)) == 0
        || strcmp(argumentType, @encode(void (^)())) == 0
    ) {
        __unsafe_unretained id argument = nil;
        [invocation getArgument:&argument atIndex:index];
        return argument;
    }
    RETURN_VALUE(char)
    RETURN_VALUE(int)
    RETURN_VALUE(short)
    RETURN_VALUE(long)
    RETURN_VALUE(long long)
    RETURN_VALUE(unsigned char)
    RETURN_VALUE(unsigned int)
    RETURN_VALUE(unsigned short)
    RETURN_VALUE(unsigned long)
    RETURN_VALUE(unsigned long long)
    RETURN_VALUE(float)
    RETURN_VALUE(double)
    RETURN_VALUE(BOOL)
    RETURN_VALUE(const char *)
    else {
        NSUInteger size = 0;
        NSGetSizeAndAlignment(argumentType, &size, NULL);
        NSCParameterAssert(size > 0);
        uint8_t data[size];
        [invocation getArgument:&data atIndex:index];
        
        return [NSValue valueWithBytes:&data objCType:argumentType];
    }
}

BOOL RX_is_method_void(NSInvocation *invocation) {
    const char *methodReturnType = invocation.methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}

BOOL RX_is_method_with_description_void(struct objc_method_description method) {
    return strncmp(method.types, @encode(void), 1) == 0;
}

NSArray *RX_extract_arguments(NSInvocation *invocation) {
    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    NSUInteger numberOfVisibleArguments = numberOfArguments - HIDDEN_ARGUMENT_COUNT;
    
    NSCParameterAssert(numberOfVisibleArguments >= 0);
    NSCParameterAssert(RX_is_method_void(invocation));
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfVisibleArguments];
    
    for (NSUInteger index = HIDDEN_ARGUMENT_COUNT; index < numberOfArguments; ++index) {
        [arguments addObject:RX_extract_argument_at_index(invocation, index) ?: [NSNull null]];
    }
    
    return arguments;
}

@interface _RXDelegateProxy ()

@property (nonatomic, strong) id strongForwardDelegate;

@end

static NSMutableDictionary *forwardableSelectorsPerClass = nil;

@implementation _RXDelegateProxy

+(void)initialize {
    @synchronized (_RXDelegateProxy.class) {
        if (forwardableSelectorsPerClass == nil) {
            forwardableSelectorsPerClass = [[NSMutableDictionary alloc] init];
        }

        // NSLog(@"Class: %@", NSStringFromClass(self));
        
        NSMutableSet *allowedSelectors = [NSMutableSet set];
     
        unsigned int count;
        Protocol *__unsafe_unretained *pProtocols = class_copyProtocolList(self, &count);
        
        for (unsigned int i = 0; i < count; i++) {
            
            unsigned int protocolMethodCount = 0;
            Protocol *protocol = pProtocols[i];
            struct objc_method_description *methods = protocol_copyMethodDescriptionList(protocol, NO, YES, &protocolMethodCount);
            
            for (unsigned int j = 0; j < protocolMethodCount; ++j) {
                struct objc_method_description method = methods[j];
                if (RX_is_method_with_description_void(method)) {
                    // NSLog(@"Allowed selector: %@", NSStringFromSelector(method.name));
                    [allowedSelectors addObject:SEL_VALUE(method.name)];
                }
            }
            
            free(methods);
        }
        
        free(pProtocols);
        
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
    if (RX_is_method_void(anInvocation)) {
        NSArray *arguments = RX_extract_arguments(anInvocation);
        [self interceptedSelector:anInvocation.selector withArguments:arguments];
    }
    
    //NSLog(@"Sent selector %@", NSStringFromSelector(anInvocation.selector));
    if (self._forwardToDelegate && [self._forwardToDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self._forwardToDelegate];
    }
}

-(void)dealloc {
}

@end
