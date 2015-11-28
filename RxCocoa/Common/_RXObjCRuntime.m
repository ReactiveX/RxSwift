//
//  RXObjCRuntime.m
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <pthread.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import <libkern/OSAtomic.h>

#import "_RX.h"
#import "_RXObjcRuntime.h"

#if !DISABLE_SWIZZLING

// self + cmd
#define HIDDEN_ARGUMENT_COUNT   2

typedef NSInvocation       *NSInvocationRef;
typedef NSMethodSignature  *NSMethodSignatureRef;
typedef unsigned int        rx_uint;
typedef unsigned long       rx_ulong;
typedef id (^rx_block)(id);

static CFTypeID  defaultTypeID;
static SEL       deallocSelector;

static int RxSwizzledClassKey = 0;
static int32_t numberOfSwizzledMethods = 0;

#define THREADING_HAZZARD(class) \
    NSLog(@"There was a problem swizzling on `%@`.\nYou have probably two libraries performing swizzling in runtime.\nWe didn't want to crash your program, but this is not good ...\nYou an solve this problem by either not using swizzling in this library, removing one of those other libraries, or making sure that swizzling parts are synchronized (only perform them on main thread).\nAnd yes, this message will self destruct when you clear the console, and since it's non deterministric, the problem could still exist and it will be hard for you to reproduce it.", NSStringFromClass(class)); CRASH_IN_DEBUG

#define ALWAYS(condition, message) if (!(condition)) { [NSException raise:@"RX Invalid Operator" format:@"%@", message]; }
#define ALWAYS_WITH_INFO(condition, message) NSAssert((condition), @"%@ [%@] > %@", NSStringFromClass(class), NSStringFromSelector(selector), (message))
#define C_ALWAYS(condition, message) NSCAssert((condition), @"%@ [%@] > %@", NSStringFromClass(class), NSStringFromSelector(selector), (message))

#define RX_PREFIX @"_RX_namespace_"

#define RX_ARG_id(value)          ((value) ?: [NSNull null])
#define RX_ARG_int(value)         [NSNumber numberWithInt:value]
#define RX_ARG_long(value)        [NSNumber numberWithLong:value]
#define RX_ARG_BOOL(value)        [NSNumber numberWithBool:value]
#define RX_ARG_SEL(value)         [NSNumber valueWithPointer:value]
#define RX_ARG_rx_uint(value)     [NSNumber numberWithUnsignedInt:value]
#define RX_ARG_rx_ulong(value)    [NSNumber numberWithUnsignedLong:value]
#define RX_ARG_rx_block(value)    ((id)(value) ?: [NSNull null])

typedef struct supported_type {
    const char *encoding;
} supported_type_t;

static supported_type_t supported_types[] = {
    { .encoding = @encode(id)},
    { .encoding = @encode(Class)},
    { .encoding = @encode(void (^)())},
    { .encoding = @encode(char)},
    { .encoding = @encode(short)},
    { .encoding = @encode(int)},
    { .encoding = @encode(long)},
    { .encoding = @encode(long long)},
    { .encoding = @encode(unsigned char)},
    { .encoding = @encode(unsigned short)},
    { .encoding = @encode(unsigned int)},
    { .encoding = @encode(unsigned long)},
    { .encoding = @encode(unsigned long long)},
    { .encoding = @encode(float)},
    { .encoding = @encode(double)},
    { .encoding = @encode(BOOL)},
    { .encoding = @encode(const char*)},
};

__attribute__((constructor))
static void RX_initialize_objc_runtime() {
}

BOOL RX_is_supported_type(const char *type) {
    if (type == nil) {
        return NO;
    }

    for (int i = 0; i < sizeof(supported_types) / sizeof(supported_type_t); ++i) {
        if (supported_types[i].encoding[0] != type[0]) {
            continue;
        }
        if (strcmp(supported_types[i].encoding, type) == 0) {
            return YES;
        }
    }

    return NO;
}

SEL __nonnull RX_selector(SEL __nonnull selector) {
    NSString *selectorString = NSStringFromSelector(selector);
    return NSSelectorFromString([RX_PREFIX stringByAppendingString:selectorString]);
}

BOOL RX_is_method_signature_void(NSMethodSignature * __nonnull methodSignature) {
    const char *methodReturnType = methodSignature.methodReturnType;
    return strcmp(methodReturnType, @encode(void)) == 0;
}

BOOL RX_is_method_with_description_void(struct objc_method_description method) {
    return strncmp(method.types, @encode(void), 1) == 0;
}

// inspired by https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSInvocation%2BRACTypeParsing.m
// awesome work
id __nonnull RX_extract_argument_at_index(NSInvocation * __nonnull invocation, NSUInteger index) {
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
    RETURN_VALUE(short)
    RETURN_VALUE(int)
    RETURN_VALUE(long)
    RETURN_VALUE(long long)
    RETURN_VALUE(unsigned char)
    RETURN_VALUE(unsigned short)
    RETURN_VALUE(unsigned int)
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

NSArray *RX_extract_arguments(NSInvocation *invocation) {
    NSUInteger numberOfArguments = invocation.methodSignature.numberOfArguments;
    NSUInteger numberOfVisibleArguments = numberOfArguments - HIDDEN_ARGUMENT_COUNT;
    
    NSCParameterAssert(numberOfVisibleArguments >= 0);
    
    NSMutableArray *arguments = [NSMutableArray arrayWithCapacity:numberOfVisibleArguments];
    
    for (NSUInteger index = HIDDEN_ARGUMENT_COUNT; index < numberOfArguments; ++index) {
        [arguments addObject:RX_extract_argument_at_index(invocation, index) ?: [NSNull null]];
    }
    
    return arguments;
}

void * __nonnull RX_reference_from_selector(SEL __nonnull selector) {
    return selector;
}

/*static void RX_ensure_can_swizzle(Class __nonnull class, SEL __nonnull selector) {
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
}*/

static BOOL RX_forward_invocation(id __nonnull __unsafe_unretained self, NSInvocation *invocation) {
    SEL originalSelector = RX_selector(invocation.selector);

    id<RXMessageSentObserver> messageSentObserver = objc_getAssociatedObject(self, originalSelector);

    if (messageSentObserver != nil) {
        NSArray *arguments = RX_extract_arguments(invocation);
        [messageSentObserver messageSentWithParameters:arguments];
    }

    if ([self respondsToSelector:originalSelector]) {
        invocation.selector = originalSelector;
        [invocation invokeWithTarget:self];
        return YES;
    }

    return NO;
}

static BOOL RX_responds_to_selector(id __nonnull __unsafe_unretained self, SEL selector) {
    Class class = object_getClass(self);
    if (class == nil) { return NO; }

    Method m = class_getInstanceMethod(class, selector);
    if (m != nil) { return YES; }

    return NO;
}

static NSMethodSignatureRef RX_method_signature(id __nonnull __unsafe_unretained self, SEL selector) {
    Class class = object_getClass(self);
    if (class == nil) { return nil; }

    Method method = class_getInstanceMethod(class, selector);
    if (method == nil) { return nil; }

    const char *encoding = method_getTypeEncoding(method);
    if (encoding == nil) { return nil; }

    return [NSMethodSignature signatureWithObjCTypes:encoding];
}

// inspired by
// https://github.com/mikeash/MAZeroingWeakRef/blob/master/Source/MAZeroingWeakRef.m
// https://github.com/ReactiveCocoa/ReactiveCocoa/blob/swift-development/ReactiveCocoa/Objective-C/NSObject%2BRACDeallocating.m

@interface RXObjCRuntime: NSObject

@property (nonatomic, assign) pthread_mutex_t lock;

@property (nonatomic, strong) NSMutableSet<NSValue *> *classesThatSupportObservingByForwarding;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, Class> *dynamicSublassByRealClass;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, NSMutableSet<NSValue*>*> *swizzledSelectorsByClass;

+(RXObjCRuntime*)instance;

-(void)performLocked:(void (^)(RXObjCRuntime* __nonnull))action;
-(void)ensurePrepared:(id __nonnull)target forObserving:(SEL __nonnull)selector;

@end

void RX_ensure_observing(id __nonnull target, SEL __nonnull selector) {
    [[RXObjCRuntime instance] performLocked:^(RXObjCRuntime * __nonnull self) {
        [self ensurePrepared:target forObserving:selector];
    }];
}

@implementation RXObjCRuntime

static RXObjCRuntime *_instance = nil;

+(RXObjCRuntime*)instance {
    return _instance;
}

+(void)initialize {
    _instance = [[RXObjCRuntime alloc] init];
    defaultTypeID = CFGetTypeID((CFTypeRef)RXObjCRuntime.class); // just need a reference of some object not from CF
    deallocSelector = NSSelectorFromString(@"dealloc");
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

-(void)performLocked:(void (^)(RXObjCRuntime* __nonnull))action {
    pthread_mutex_lock(&_lock);
    action(self);
    pthread_mutex_unlock(&_lock);
}

-(void)ensurePrepared:(id __nonnull)target forObserving:(SEL __nonnull)selector  {
    __unused Class swizzlingImplementorClass = [self prepareTargetClassForObserving:target];

    if ([self swizzledSelector:selector forClass:swizzlingImplementorClass]) {
        return;
    }

    if (selector == deallocSelector) {
        [self swizzleDeallocating:swizzlingImplementorClass];
    }
    else {
        [self observeByForwardingMessages:swizzlingImplementorClass
                                 selector:selector
                                   target:target];
    }

    [self swizzledSelector:selector forClass:swizzlingImplementorClass];
}

-(void)observeByForwardingMessages:(Class __nonnull)swizzlingImplementorClass
                          selector:(SEL)selector
                            target:(id __nonnull)target {
    [self ensureForwardingMethodsAreSwizzled:swizzlingImplementorClass];

    SEL rxSelector = RX_selector(selector);
    id<RXSwizzlingObserver> messageSentObserver = objc_getAssociatedObject(target, rxSelector);
    ALWAYS(messageSentObserver != nil, @"Message sent observer not set");

    Method instanceMethod = class_getInstanceMethod(swizzlingImplementorClass, selector);
    if (instanceMethod == nil) {
        [messageSentObserver methodForSelectorDoesntExist];
        return;
    }

    const char* methodEncoding = method_getTypeEncoding(instanceMethod);
    ALWAYS(methodEncoding != nil, @"Method encoding is nil.");
    NSMethodSignature *methodSignature = [NSMethodSignature signatureWithObjCTypes:methodEncoding];
    ALWAYS(methodSignature != nil, @"Method signature is invalid.");

    IMP implementation = method_getImplementation(instanceMethod);

    if (implementation == nil) {
        [messageSentObserver errorDuringSwizzling];
        return;
    }

    if (!class_addMethod(swizzlingImplementorClass, rxSelector, implementation, methodEncoding)) {
        [messageSentObserver errorDuringSwizzling];
        return;
    }

    if (!class_addMethod(swizzlingImplementorClass, selector, _objc_msgForward, methodEncoding)) {
        if (implementation != method_setImplementation(instanceMethod, _objc_msgForward)) {
            [messageSentObserver errorDuringSwizzling];
            THREADING_HAZZARD(swizzlingImplementorClass);
            return;
        }
    }

    DLOG(@"Rx uses forwarding to observe `%@` for `%@`.", NSStringFromSelector(selector), [target class]);
}

-(Class)prepareTargetClassForObserving:(id __nonnull)target {
    Class swizzlingClass = objc_getAssociatedObject(target, &RxSwizzledClassKey);
    if (swizzlingClass != nil) {
        return swizzlingClass;
    }

    Class __nonnull wannaBeClass = [target class];
    // if possibly, only limit effect to one instance
    BOOL isThisTollFreeFoundationClass = CFGetTypeID((CFTypeRef)target) != defaultTypeID;
    if ([target class] == object_getClass(target) && !isThisTollFreeFoundationClass) {
        Class dynamicFakeSubclass = [self ensureHasDynamicFakeSubclass:wannaBeClass];
        Class previousClass = object_setClass(target, dynamicFakeSubclass);
        if (previousClass != wannaBeClass) {
            THREADING_HAZZARD(wannaBeClass);
        }
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
-(Class)ensureHasDynamicFakeSubclass:(Class __nonnull)class {
    Class dynamicFakeSubclass = [self.dynamicSublassByRealClass objectForKey:CLASS_VALUE(class)];
    if (dynamicFakeSubclass != nil) {
        return dynamicFakeSubclass;
    }

    NSString *dynamicFakeSublassName = [RX_PREFIX stringByAppendingString:NSStringFromClass(class)];
    const char *dynamicFakeSublassNameRaw = dynamicFakeSublassName.UTF8String;
    dynamicFakeSubclass = objc_allocateClassPair(class, dynamicFakeSublassNameRaw, 0);
    ALWAYS(dynamicFakeSubclass != nil, @"Class not generated");

    [self swizzleClass:dynamicFakeSubclass toActAs:class];
    [self ensureForwardingMethodsAreSwizzled:dynamicFakeSubclass];

    objc_registerClassPair(dynamicFakeSubclass);

    [self.dynamicSublassByRealClass setObject:dynamicFakeSubclass forKey:CLASS_VALUE(class)];
    ALWAYS([self.dynamicSublassByRealClass objectForKey:CLASS_VALUE(class)] != nil, @"Class not registered");

    return dynamicFakeSubclass;
}

-(void)ensureForwardingMethodsAreSwizzled:(Class __nonnull)class {
    NSValue *classValue = CLASS_VALUE(class);
    if ([self.classesThatSupportObservingByForwarding containsObject:classValue]) {
        return;
    }

    [self swizzleForwardInvocation:class];
    [self swizzleMethodSignatureForSelector:class];
    [self swizzleRespondsToSelector:class];

    [self.classesThatSupportObservingByForwarding addObject:classValue];
}

-(void)registerSwizzledSelector:(SEL)selector forClass:(Class)class {
    NSValue * __nonnull classValue = CLASS_VALUE(class);
    NSValue * __nonnull selectorValue = SEL_VALUE(selector);

    NSMutableSet *swizzledSelectorsForClass = self.swizzledSelectorsByClass[classValue];

    if (swizzledSelectorsForClass == nil) {
        swizzledSelectorsForClass = [NSMutableSet set];
        [self.swizzledSelectorsByClass setObject:swizzledSelectorsForClass forKey:classValue];
    }

    [swizzledSelectorsForClass addObject:selectorValue];

    ALWAYS([[self.swizzledSelectorsByClass objectForKey:classValue] containsObject:selectorValue], @"Class should have been swizzled");
}

-(BOOL)swizzledSelector:(SEL)selector forClass:(Class)class {
    NSValue * __nonnull classValue = CLASS_VALUE(class);
    NSValue * __nonnull selectorValue = SEL_VALUE(selector);

    NSMutableSet *swizzledSelectorsForClass = self.swizzledSelectorsByClass[classValue];

    return [swizzledSelectorsForClass containsObject:selectorValue];
}

-(void)ensureSwizzledSelector:(SEL __nonnull)selector
                      ofClass:(Class __nonnull)class
   newImplementationGenerator:(IMP(^)())newImplementationGenerator
replacementImplementationGenerator:(IMP (^)(IMP originalImplemenation))replacementImplementationGenerator {
    if ([self swizzledSelector:selector forClass:class]) {
        return;
    }

    OSAtomicIncrement32(&numberOfSwizzledMethods);
    
    DLOG(@"Rx is swizzling `%@` for `%@`", NSStringFromSelector(selector), class);

    [self registerSwizzledSelector:selector forClass:class];

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
    ALWAYS(originalImplementation != nil, @"Method must exist.");
    IMP implementationReplacementIMP = replacementImplementationGenerator(originalImplementation);
    ALWAYS(implementationReplacementIMP != nil, @"Method must exist.");
    IMP originalImplementationAfterChange = method_setImplementation(existingMethodOnTargetClass, implementationReplacementIMP);
    ALWAYS(originalImplementation != nil, @"Method must exist.");

    // ¯\_(ツ)_/¯
    if (originalImplementationAfterChange != originalImplementation) {
        THREADING_HAZZARD(class);
    }
}

// bodies

#define FORWARD_BODY(invocation)                        if (RX_forward_invocation(self, NAME_CAT(_, 0, invocation))) { return; }

#define RESPONDS_TO_SELECTOR_BODY(selector)             if (RX_responds_to_selector(self, NAME_CAT(_, 0, selector))) return YES;

#define CLASS_BODY(...)                                 return class;

#define METHOD_SIGNATURE_FOR_SELECTOR_BODY(selector)                                            \
    NSMethodSignatureRef methodSignature = RX_method_signature(self, NAME_CAT(_, 0, selector)); \
    if (methodSignature != nil) {                                                               \
        return methodSignature;                                                                 \
    }

#define DEALLOCATING_BODY(...)                                                        \
    id<RXDeallocatingObserver> observer = objc_getAssociatedObject(self, rxSelector); \
    if (observer != nil) {                                                            \
        [observer deallocating];                                                      \
    }

#define OBSERVE_BODY(...)                                                               \
    id<RXMessageSentObserver> observer = objc_getAssociatedObject(self, rxSelector);    \
                                                                                        \
    if (observer != nil) {                                                              \
        [observer messageSentWithParameters:@[COMMA_DELIMITED_ARGUMENTS(__VA_ARGS__)]]; \
    }                                                                                   \


#define BUILD_ARG_WRAPPER(type)                   RX_ARG_ ## type                                                          //RX_ARG_ ## type
#define CAT(_1, _2, head, tail)                   RX_CAT2(head, tail)
#define SEPARATE_BY_COMMA(_1, _2, head, tail)     head, tail
#define SEPARATE_BY_UNDERSCORE(head, tail)        RX_CAT2(RX_CAT2(head, _), tail)
#define UNDERSCORE_TYPE_CAT(_1, index, type)      RX_CAT2(_, type)                                                    // generates -> , _type
#define NAME_CAT(_1, index, type)                 SEPARATE_BY_UNDERSCORE(type, index)                                 // generates -> , type_0
#define TYPE_AND_NAME_CAT(_1, index, type)        type SEPARATE_BY_UNDERSCORE(type, index)                            // generates -> , type type_0
#define NOT_NULL_ARGUMENT_CAT(_1, index, type)    BUILD_ARG_WRAPPER(type)(NAME_CAT(_1, index, type))

#define COMMA_DELIMITED_ARGUMENTS(...)            RX_FOR(_, SEPARATE_BY_COMMA, NOT_NULL_ARGUMENT_CAT, ## __VA_ARGS__)
#define ARGUMENTS(...)                            RX_FOR_COMMA(_, NAME_CAT, ## __VA_ARGS__)
#define DECLARE_ARGUMENTS(...)                    RX_FOR_COMMA(_, TYPE_AND_NAME_CAT, ## __VA_ARGS__)

// optimized observe methods

#define GENERATE_METHOD_IDENTIFIER(...)          RX_CAT2(swizzle, RX_FOR(_, CAT, UNDERSCORE_TYPE_CAT, ## __VA_ARGS__))

#define GENERATE_OBSERVE_METHOD_DECLARATION(...) -(void)GENERATE_METHOD_IDENTIFIER(__VA_ARGS__):(Class __nonnull)class selector:(SEL)selector {

#define SWIZZLE_OBSERVE_METHOD(return_value, ...) \
    SWIZZLE_METHOD(return_value, GENERATE_OBSERVE_METHOD_DECLARATION(return_value, ## __VA_ARGS__), OBSERVE_BODY, ## __VA_ARGS__)

// infrastructure method

#define SWIZZLE_INFRASTRUCTURE_METHOD(return_value, method_name, parameters, method_selector, body, ...) \
    SWIZZLE_METHOD(return_value, -(void)method_name:(Class __nonnull)class parameters { SEL selector = method_selector; , body, __VA_ARGS__)

// common base

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
    [self ensureSwizzledSelector:selector                                                                                \
                          ofClass:class                                                                                  \
       newImplementationGenerator:newImplementationGenerator                                                             \
replacementImplementationGenerator:replacementImplementationGenerator];                                                  \
}

SWIZZLE_INFRASTRUCTURE_METHOD(
    void,
    swizzleForwardInvocation,
    ,
    @selector(forwardInvocation:),
    FORWARD_BODY,
    NSInvocationRef
)
SWIZZLE_INFRASTRUCTURE_METHOD(
    BOOL,
    swizzleRespondsToSelector,
    ,
    @selector(respondsToSelector:),
    RESPONDS_TO_SELECTOR_BODY,
    SEL
)
SWIZZLE_INFRASTRUCTURE_METHOD(
    Class __nonnull,
    swizzleClass,
    toActAs:(Class)actAsClass,
    @selector(class),
    CLASS_BODY
)
SWIZZLE_INFRASTRUCTURE_METHOD(
    NSMethodSignatureRef,
    swizzleMethodSignatureForSelector,
    ,
    @selector(methodSignatureForSelector:),
    METHOD_SIGNATURE_FOR_SELECTOR_BODY,
    SEL
)
SWIZZLE_INFRASTRUCTURE_METHOD(
    void,
    swizzleDeallocating,
    ,
    deallocSelector,
    DEALLOCATING_BODY
)

SWIZZLE_OBSERVE_METHOD(void)

SWIZZLE_OBSERVE_METHOD(void, id)
SWIZZLE_OBSERVE_METHOD(void, int)
SWIZZLE_OBSERVE_METHOD(void, long)
SWIZZLE_OBSERVE_METHOD(void, BOOL)
SWIZZLE_OBSERVE_METHOD(void, SEL)
SWIZZLE_OBSERVE_METHOD(void, rx_uint)
SWIZZLE_OBSERVE_METHOD(void, rx_ulong)
SWIZZLE_OBSERVE_METHOD(void, rx_block)

SWIZZLE_OBSERVE_METHOD(void, id, id)
SWIZZLE_OBSERVE_METHOD(void, id, int)
SWIZZLE_OBSERVE_METHOD(void, id, long)
SWIZZLE_OBSERVE_METHOD(void, id, BOOL)
SWIZZLE_OBSERVE_METHOD(void, id, SEL)
SWIZZLE_OBSERVE_METHOD(void, id, rx_uint)
SWIZZLE_OBSERVE_METHOD(void, id, rx_ulong)
SWIZZLE_OBSERVE_METHOD(void, id, rx_block)
@end

#if DEBUG

NSInteger RX_number_of_dynamic_subclasses() {
    __block NSInteger count = 0;
    [[RXObjCRuntime instance] performLocked:^(RXObjCRuntime * __nonnull self) {
        count = self.dynamicSublassByRealClass.count;
    }];

    return count;
}

NSInteger RX_number_of_forwarding_enabled_classes() {
    __block NSInteger count = 0;
    [[RXObjCRuntime instance] performLocked:^(RXObjCRuntime * __nonnull self) {
        count = self.classesThatSupportObservingByForwarding.count;
    }];

    return count;
}

NSInteger RX_number_of_swizzled_classes() {
    __block NSInteger count = 0;
    [[RXObjCRuntime instance] performLocked:^(RXObjCRuntime * __nonnull self) {
        count = self.swizzledSelectorsByClass.count;
    }];

    return count;
}

NSInteger RX_number_of_swizzled_methods() {
    return numberOfSwizzledMethods;
}

#endif

#endif