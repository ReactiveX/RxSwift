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

typedef NSInvocation * NSInvocationRef;
typedef NSMethodSignature * NSMethodSignatureRef;
typedef unsigned int rx_uint;
typedef unsigned long rx_ulong;
typedef id (^rx_block)(id);

#if !DISABLE_SWIZZLING

#define ALWAYS(condition, message) if (!(condition)) { [NSException raise:@"RX Invalid Operator" format:@"%@", message]; }
#define ALWAYS_WITH_INFO(condition, message) NSAssert((condition), @"%@ [%@] > %@", NSStringFromClass(class), NSStringFromSelector(selector), (message))
#define C_ALWAYS(condition, message) NSCAssert((condition), @"%@ [%@] > %@", NSStringFromClass(class), NSStringFromSelector(selector), (message))

#define RX_PREFIX @"_RX_"

static int RxSwizzledClassKey = 0;

SEL __nonnull RX_selector(SEL __nonnull selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    return NSSelectorFromString([RX_PREFIX stringByAppendingString:selectorString]);
}

#define RX_ARG_id(value)          ((value) ?: [NSNull null])
#define RX_ARG_int(value)         [NSNumber numberWithInt:value]
#define RX_ARG_long(value)        [NSNumber numberWithLong:value]
#define RX_ARG_BOOL(value)        [NSNumber numberWithBool:value]
#define RX_ARG_SEL(value)         [NSNumber valueWithPointer:value]
#define RX_ARG_rx_uint(value)     [NSNumber numberWithUnsignedInt:value]
#define RX_ARG_rx_ulong(value)    [NSNumber numberWithUnsignedLong:value]
#define RX_ARG_rx_block(value)    ((value) ?: [NSNull null])

void * __nonnull RX_reference_from_selector(SEL __nonnull selector) {
    return selector;
}

void RX_ensure_can_swizzle(Class __nonnull class, SEL __nonnull selector) {
    Method existingMethod = class_getInstanceMethod(class, selector);

    C_ALWAYS(existingMethod != nil, @"Method is nil");
    const char *encoding = method_getTypeEncoding(existingMethod);
    NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:encoding];

    NSLog(@"%s", signature.methodReturnType);
    NSUInteger numberOfArguments = signature.numberOfArguments;
    for (NSUInteger i = 0; i < numberOfArguments; ++i) {
        NSLog(@"%s", [signature getArgumentTypeAtIndex:i]);
        [signature getArgumentTypeAtIndex:i];
    }
    C_ALWAYS(strcmp(signature.methodReturnType, @encode(void)) == 0, @"Method is not void");
}

void RX_ForwardInvocation(id __nonnull self, NSInvocation *invocation) {

}

BOOL RX_RespondsToSelector(id __nonnull self, SEL selector) {
    return NO;
}

NSMethodSignatureRef RX_MethodSignature(id __nonnull self, SEL selector) {
    Class class = object_getClass(self);
    if (class == nil) {
        return nil;
    }

    Method method = class_getInstanceMethod(class, selector);
    if (method == nil) {
        return nil;
    }

    const char *encoding = method_getTypeEncoding(method);

    if (encoding == nil) {
        return nil;
    }

    return [NSMethodSignature signatureWithObjCTypes:encoding];
}

// inspired by
// https://github.com/mikeash/MAZeroingWeakRef/blob/master/Source/MAZeroingWeakRef.m
// https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSObject%2BRACDeallocating.m

@interface RXSwizzling: NSObject

@property (nonatomic, assign) pthread_mutex_t lock;

@property (nonatomic, strong) NSMutableSet<NSValue *> *classesThatSupportObservingByForwarding;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, Class> *dynamicSublassByRealClass;
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

    self.classesThatSupportObservingByForwarding = [NSMutableSet set];
    self.dynamicSublassByRealClass = [NSMutableDictionary dictionary];
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

-(void)ensureSwizzled:(id __nonnull)target forObserving:(SEL __nonnull)selector  {
    __unused Class swizzlingImplementorClass = [self ensurePreparedForSwizzling:target];

    /*
    Method instanceMethod = class_getInstanceMethod(class, selector);
    const char* methodEncoding = method_getTypeEncoding(instanceMethod);
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodEncoding];

    // if method signature is not void
    if (!RX_is_method_signature_void(methodSignature)) {
        
    }*/
}

-(Class)ensurePreparedForSwizzling:(id __nonnull)target {
    Class swizzlingClass = objc_getAssociatedObject(target, &RxSwizzledClassKey);
    if (swizzlingClass != nil) {
        return swizzlingClass;
    }

    Class __nonnull wannaBeClass = [target class];
    // if possibly, only limit effect to one instance
    if ([target class] == object_getClass(target)) {
        Class dynamicFakeSubclass = [self ensureDynamicFakeSubclass:wannaBeClass];
        object_setClass(target, dynamicFakeSubclass);
        objc_setAssociatedObject(target, &RxSwizzledClassKey, dynamicFakeSubclass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return dynamicFakeSubclass;
    }

    // biggest performance penalty, swizzling all instances of original class
    objc_setAssociatedObject(target, &RxSwizzledClassKey, wannaBeClass, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return wannaBeClass;
}

/**
 If object don't have some weird behavior, claims it's the same class that runtime shows,
 then dynamic subclass is created (only this instance will have performance hit).
 
 In case something weird is detected, then original base class is being swizzled and all instances
 will have somewhat reduced performance.
 
 This is especially handy optimization for weak KVO. Nobody will swizzle for example `NSString`,
 but to know when instance of a `NSString` was deallocated, performance hit will be only felt on a 
 single instance of `NSString`, not all instances of `NSString`s.
 */
-(Class)ensureDynamicFakeSubclass:(Class __nonnull)class {
    Class dynamicFakeSubclass = [self.dynamicSublassByRealClass objectForKey:CLASS_VALUE(class)];
    if (dynamicFakeSubclass != nil) {
        return dynamicFakeSubclass;
    }

    NSString *dynamicFakeSublassName = [RX_PREFIX stringByAppendingString:NSStringFromClass(class)];
    dynamicFakeSubclass = objc_allocateClassPair(class, dynamicFakeSublassName.UTF8String, 0);
    ALWAYS(dynamicFakeSubclass != nil, @"Class not generated");

    [self ensureForwardingMethodsAreHandled:dynamicFakeSubclass toActAs:class];

    [self.dynamicSublassByRealClass setObject:dynamicFakeSubclass forKey:CLASS_VALUE(class)];
    return dynamicFakeSubclass;
}

-(void)ensureForwardingMethodsAreHandled:(Class __nonnull)class toActAs:(Class __nonnull)toActAs {
    NSValue *classValue = CLASS_VALUE(class);
    if ([self.classesThatSupportObservingByForwarding containsObject:classValue]) {
        return;
    }

    [self swizzleForwardInvocation:class];
    [self swizzleMethodSignatureForSelector:class];
    [self swizzleRespondsToSelector:class];
    [self swizzleClass:class toActAs:toActAs];

    [self.classesThatSupportObservingByForwarding addObject:classValue];
}

#define FORWARD_BODY(invocation)                        RX_ForwardInvocation(self, NAME_CAT(_, 0, invocation));
#define RESPONDS_TO_SELECTOR_BODY(selector)             if (RX_RespondsToSelector(self, NAME_CAT(_, 0, selector))) return YES;
#define CLASS_BODY(...)                                 return class;
#define METHOD_SIGNATURE_FOR_SELECTOR_BODY(selector)                                           \
    NSMethodSignatureRef methodSignature = RX_MethodSignature(self, NAME_CAT(_, 0, selector)); \
    if (methodSignature != nil) {                                                              \
        return methodSignature;                                                                \
    }

#define OBSERVE_BODY(...)                                                          \
    id<RXMessageSentObserver> action = objc_getAssociatedObject(self, rxSelector); \
                                                                                   \
    if (action != nil) {                                                           \
        [action messageSentWithParameters:@[]];                                    \
    }                                                                              \


#define CAT(_1, _2, head, tail)                 RX_CAT2(head, tail)
#define SEPARATE_BY_UNDERSCORE(head, tail)      RX_CAT2(RX_CAT2(head, _), tail)
#define UNDERSCORE_TYPE_CAT(_1, index, type)    RX_CAT2(_, type)                         // generates -> , _type
#define NAME_CAT(_1, index, type)               SEPARATE_BY_UNDERSCORE(type, index)      // generates -> , type_0
#define TYPE_AND_NAME_CAT(_1, index, type)      type SEPARATE_BY_UNDERSCORE(type, index) // generates -> , type type_0

#define ARGUMENTS(...)                           RX_FOR_COMMA(_, NAME_CAT, ## __VA_ARGS__)
#define DECLARE_ARGUMENTS(...)                   RX_FOR_COMMA(_, TYPE_AND_NAME_CAT, ## __VA_ARGS__)

#define GENERATE_METHOD_IDENTIFIER(...)          RX_CAT2(swizzle, RX_FOR(_, CAT, UNDERSCORE_TYPE_CAT, ## __VA_ARGS__))

// generation of forwarding methods

#define GENERATE_OBSERVE_METHOD_DECLARATION(...) -(void)GENERATE_METHOD_IDENTIFIER(__VA_ARGS__):(Class __nonnull)class selector:(SEL)selector {

#define SWIZZLE_OBSERVE_METHOD(return_value, body, ...) \
    SWIZZLE_METHOD(return_value, GENERATE_OBSERVE_METHOD_DECLARATION(return_value, ## __VA_ARGS__), body, ## __VA_ARGS__)

#define SWIZZLE_INFRASTRUCTURE_METHOD(return_value, method_name, parameters, method_selector, body, ...) \
    SWIZZLE_METHOD(return_value, -(void)method_name:(Class __nonnull)class parameters { SEL selector = @selector(method_selector); , body, __VA_ARGS__)

#define SWIZZLE_METHOD(return_value, method_prototype, body, ...)                                                        \
method_prototype                                                                                                         \
    __unused SEL rxSelector = RX_selector(selector);                                                                     \
    IMP (^newImplementationGenerator)() = ^() {                                                                          \
        id newImplementation = ^return_value(__unsafe_unretained id self DECLARE_ARGUMENTS(__VA_ARGS__)) {               \
            body(__VA_ARGS__)                                                                                            \
                                                                                                                         \
            struct objc_super superInfo = {                                                                              \
                .receiver = self,                                                                                        \
                .super_class = class_getSuperclass(class)                                                                \
            };                                                                                                           \
                                                                                                                         \
            return_value (*msgSend)(struct objc_super *, SEL DECLARE_ARGUMENTS(__VA_ARGS__))                             \
                = (__typeof__(msgSend))objc_msgSendSuper;                                                                \
            return msgSend(&superInfo, selector ARGUMENTS(__VA_ARGS__));                                                 \
        };                                                                                                               \
                                                                                                                         \
        return imp_implementationWithBlock(newImplementation);                                                           \
    };                                                                                                                   \
                                                                                                                         \
    IMP (^replacementImplementationGenerator)(IMP) = ^(IMP originalImplementation) {                                     \
        __block return_value (*originalImplementationTyped)(__unsafe_unretained id, SEL DECLARE_ARGUMENTS(__VA_ARGS__) ) \
            = (__typeof__(originalImplementationTyped))(originalImplementation);                                         \
                                                                                                                         \
        id implementationReplacement = ^return_value(__unsafe_unretained id self DECLARE_ARGUMENTS(__VA_ARGS__) ) {      \
            body(__VA_ARGS__)                                                                                            \
                                                                                                                         \
            return originalImplementationTyped(self, selector ARGUMENTS(__VA_ARGS__));                                   \
        };                                                                                                               \
                                                                                                                         \
        return imp_implementationWithBlock(implementationReplacement);                                                   \
    };                                                                                                                   \
                                                                                                                         \
    [self _ensureSwizzledSelector:selector                                                                               \
                          ofClass:class                                                                                  \
       newImplementationGenerator:newImplementationGenerator                                                             \
replacementImplementationGenerator:replacementImplementationGenerator];                                                  \
}

SWIZZLE_INFRASTRUCTURE_METHOD(void, swizzleForwardInvocation, , forwardInvocation:, FORWARD_BODY, NSInvocationRef)
SWIZZLE_INFRASTRUCTURE_METHOD(BOOL, swizzleRespondsToSelector, , respondsToSelector:, RESPONDS_TO_SELECTOR_BODY, SEL)
SWIZZLE_INFRASTRUCTURE_METHOD(Class __nonnull, swizzleClass, toActAs:(Class)actAsClass, class, CLASS_BODY)
SWIZZLE_INFRASTRUCTURE_METHOD(NSMethodSignatureRef, swizzleMethodSignatureForSelector, , methodSignatureForSelector:, METHOD_SIGNATURE_FOR_SELECTOR_BODY, SEL)

-(void)_ensureSwizzledSelector:(SEL __nonnull)selector
                      ofClass:(Class __nonnull)class
   newImplementationGenerator:(IMP(^)())newImplementationGenerator
replacementImplementationGenerator:(IMP (^)(IMP originalImplemenation))replacementImplementationGenerator {

    NSValue * __nonnull classValue = CLASS_VALUE(class);
    NSValue * __nonnull selectorValue = SEL_VALUE(selector);

    NSMutableSet *swizzledSelectorsForClass = self.swizzledSelectorsByClass[classValue];

    if ([swizzledSelectorsForClass containsObject:selectorValue]) {
        return;
    }
    
    DLOG(@"Rx is swizzling `%@` for `%@`", NSStringFromSelector(selector), class);

    if (swizzledSelectorsForClass == nil) {
        swizzledSelectorsForClass = [NSMutableSet set];
        [self.swizzledSelectorsByClass setObject:swizzledSelectorsForClass forKey:classValue];
    }

    [swizzledSelectorsForClass addObject:selectorValue];

    ALWAYS([[self.swizzledSelectorsByClass objectForKey:classValue] containsObject:selectorValue], @"Class should have been swizzled");

    Method existingMethod = class_getInstanceMethod(class, selector);

    ALWAYS(existingMethod != nil, @"Method doesn't exist");

    const char *encoding = method_getTypeEncoding(existingMethod);
    ALWAYS(encoding != nil, @"Encoding is nil");

    IMP newImplementation = newImplementationGenerator();

    if (class_addMethod(class, selector, newImplementation, encoding)) {
        // new method added, job done
        return;
    }

    imp_removeBlock(newImplementation);

    // if add fails, that means that method already exists on targetClass
    Method existingMethodOnTargetClass = existingMethod;

    IMP originalImplementation = method_getImplementation(existingMethodOnTargetClass);
    IMP implementationReplacementIMP = replacementImplementationGenerator(originalImplementation);
    ALWAYS(originalImplementation != nil, @"Method must exist.");
    IMP originalImplementationAfterChange = method_setImplementation(existingMethodOnTargetClass, implementationReplacementIMP);
    ALWAYS(originalImplementation != nil, @"Method must exist.");

    // ¯\_(ツ)_/¯
    if (originalImplementationAfterChange != originalImplementation) {
        NSLog(@"There was a problem swizzling `%@` on `%@`.\nYou have probably two libraries performing swizzling in runtime.\nWe didn't want to crash your program, but this is not good ...\nYou an solve this problem by either not using swizzling in this library, removing one of those other libraries, or making sure that swizzling parts are synchronized (only perform them on main thread).\nAnd yes, this message will self destruct when you clear the console, and since it's non deterministric, the problem could still exist and it will be hard for you to reproduce it.", NSStringFromSelector(selector), NSStringFromClass(class));
    }
}

@end

void RX_ensure_observing(id __nonnull target, SEL __nonnull selector) {
    [[RXSwizzling instance] performLocked:^{
        [[RXSwizzling instance] ensureSwizzled:target forObserving:selector];
    }];
}

#endif