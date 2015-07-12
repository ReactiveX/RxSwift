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

// inspired by
// https://github.com/mikeash/MAZeroingWeakRef/blob/master/Source/MAZeroingWeakRef.m
// https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSObject%2BRACDeallocating.m

int RXDeallocatingAssociatedActionTag = 0;
void * const RXDeallocatingAssociatedAction = &RXDeallocatingAssociatedActionTag;

@interface RXSwizzling: NSObject

@property (nonatomic, assign) pthread_mutex_t lock;

@property (nonatomic, strong) NSMutableSet *swizzledDeallocClasses;

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
    
    self.swizzledDeallocClasses = [NSMutableSet set];
    
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

-(void)ensureSwizzledDealloc:(Class)targetClass {
    if ([self.swizzledDeallocClasses containsObject:targetClass]) {
        return;
    }
    
    DLOG(@"Rx is swizzling dealloc for: %@", targetClass);
    [self.swizzledDeallocClasses addObject:targetClass];
    NSAssert([self.swizzledDeallocClasses containsObject:targetClass], @"Class should have been swizzled");
    
    __block void (*originalDealloc)(__unsafe_unretained id, SEL) = NULL;
    
    SEL deallocSelector = sel_registerName("dealloc");
    
    id swizzledDealloc = ^(__unsafe_unretained id self) {
        id<RXDeallocating> action = objc_getAssociatedObject(self, RXDeallocatingAssociatedAction);
        
        if (action != nil) {
            [action deallocating];
        }
        
        if (originalDealloc == NULL) {
            struct objc_super superInfo = {
                .receiver = self,
                .super_class = class_getSuperclass(targetClass)
            };
            
            void (*msgSend)(struct objc_super *, SEL) = (__typeof__(msgSend))objc_msgSendSuper;
            msgSend(&superInfo, deallocSelector);
        } else {
            originalDealloc(self, deallocSelector);
        }
    };
    
    IMP swizzledDeallocIMP = imp_implementationWithBlock(swizzledDealloc);
    
    if (!class_addMethod(targetClass, deallocSelector, swizzledDeallocIMP, "v@:")) {
        Method deallocMethod = class_getInstanceMethod(targetClass, deallocSelector);
        
        originalDealloc = (__typeof__(originalDealloc))method_getImplementation(deallocMethod);
        originalDealloc = (__typeof__(originalDealloc))method_setImplementation(deallocMethod, swizzledDeallocIMP);
    }
}

@end

void RX_ensure_deallocating_swizzled(Class targetClass) {
    [[RXSwizzling instance] performLocked:^{
        [[RXSwizzling instance] ensureSwizzledDealloc:targetClass];
    }];
}

#endif