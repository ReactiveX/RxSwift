//
//  _RXSwizzling.m
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <pthread.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

#import "_RX.h"
#import "_RXSwizzling.h"

#if !DISABLE_SWIZZLING

SEL _Nonnull RX_selector(SEL __nonnull selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    return NSSelectorFromString([@"_RX_" stringByAppendingString:selectorString]);
}

void * __nonnull RX_reference_from_selector(SEL __nonnull selector) {
    return selector;
}

/*static Method RX_methodImplementation(Class __nonnull class, SEL __nonnull selector) {
    NSCAssert(class != nil, @"Target class is nil");
    NSCAssert(selector != nil, @"Selector is nil");

    unsigned int methodCount = 0;

    Method *methods = class_copyMethodList(class, &methodCount);
    NSCAssert(methods != nil, @"Methods are nil");

    @try {
        for (unsigned int i = 0; i < methodCount; ++i) {
            Method method = methods[i];
            if (method_getName(method) == selector) {
                return method;
            }
        }
    }
    @finally {
        free(methods);
    }
}*/

// inspired by
// https://github.com/mikeash/MAZeroingWeakRef/blob/master/Source/MAZeroingWeakRef.m
// https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSObject%2BRACDeallocating.m

@interface RXSwizzling: NSObject

@property (nonatomic, assign) pthread_mutex_t lock;

@property (nonatomic, strong) NSMutableDictionary<NSValue *, NSMutableSet<NSValue*>*> *swizzledSelectorsByClass;

@end

@implementation RXSwizzling

static RXSwizzling *_instance = nil;

+(RXSwizzling*)instance {
    return _instance;
}

+(void)initialize {
    _instance = [[RXSwizzling alloc] init];
    NSAssert(_instance != nil, @"Failed to initialize swizzling");
}

-(instancetype)init {
    self = [super init];
    if (!self) return nil;
    
    self.swizzledSelectorsByClass = [NSMutableDictionary dictionary];

    pthread_mutexattr_t lock_attr;
    pthread_mutexattr_init(&lock_attr);
    pthread_mutexattr_settype(&lock_attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&_lock, &lock_attr);
    pthread_mutexattr_destroy(&lock_attr);
    
    return self;
}

-(void)performLocked:(void (^)())action {
    pthread_mutex_lock(&_lock);
    action();
    pthread_mutex_unlock(&_lock);
}

-(void)ensureSwizzledSelector:(SEL __nonnull)selector ofClass:(Class __nonnull)targetClass {
    NSValue * __nonnull classValue = CLASS_VALUE(targetClass);
    NSValue * __nonnull selectorValue = SEL_VALUE(selector);

    NSMutableSet *swizzledSelectorsForClass = self.swizzledSelectorsByClass[classValue];

    if ([swizzledSelectorsForClass containsObject:selectorValue]) {
        return;
    }
    
    DLOG(@"Rx is swizzling dealloc for: %@", targetClass);

    if (swizzledSelectorsForClass == nil) {
        swizzledSelectorsForClass = [NSMutableSet set];
        [self.swizzledSelectorsByClass setObject:swizzledSelectorsForClass forKey:classValue];
    }

    [swizzledSelectorsForClass addObject:selectorValue];

    NSAssert([[self.swizzledSelectorsByClass objectForKey:classValue] containsObject:selectorValue], @"Class should have been swizzled");

    SEL rxSelector = RX_selector(selector);

    void (^basicImplementation)() = ^(__unsafe_unretained id self) {
        id<RXMessageSentObserver> action = objc_getAssociatedObject(self, rxSelector);
        
        if (action != nil) {
            [action messageSentWithParameters:@[]];
        }
    };

    id newImplementation = ^(__unsafe_unretained id self) {
        basicImplementation(self);
        struct objc_super superInfo = {
            .receiver = self,
            .super_class = class_getSuperclass(targetClass)
        };

        void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
        msgSend(&superInfo, selector);
    };

    IMP newImplementationIMP = imp_implementationWithBlock(newImplementation);

    Method existingMethod = class_getInstanceMethod(targetClass, selector);

    NSAssert(existingMethod != nil, @"Method for selector `%@` doesn't exist on `%@`.", NSStringFromSelector(selector), NSStringFromClass(targetClass));

    const char *encoding = method_getTypeEncoding(existingMethod);
    if (class_addMethod(targetClass, selector, newImplementationIMP, encoding)) {
        // new dealloc method added, job done
        return;
    }

    // if add fails, that means that method already exists on targetClass
    Method existingMethodOnTargetClass = existingMethod;

    // implementation needs to be replaced
    __block void (*originalImplementation)(__unsafe_unretained id, SEL) = NULL;

    id implementationReplacement = ^(__unsafe_unretained id self, SEL selector) {
        basicImplementation(self, selector);

        originalImplementation(self, selector);
    };

    IMP implementationReplacementIMP = imp_implementationWithBlock(implementationReplacement);

    originalImplementation = (__typeof__(originalImplementation))method_getImplementation(existingMethodOnTargetClass);
    NSAssert(originalImplementation != nil, @"Method must exist.");
    originalImplementation = (__typeof__(originalImplementation))method_setImplementation(existingMethodOnTargetClass, implementationReplacementIMP);
    NSAssert(originalImplementation != nil, @"Method must exist.");
}

@end

void RX_ensure_swizzled(Class __nonnull targetClass, SEL __nonnull selector) {
    NSCAssert(targetClass != nil, @"Target class is nil");
    NSCAssert(selector != nil, @"Selector is nil");
    [[RXSwizzling instance] performLocked:^{
        [[RXSwizzling instance] ensureSwizzledSelector:selector ofClass:targetClass];
    }];
}

#endif