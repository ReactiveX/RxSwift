//
//  RXObjCRuntime+Testing.m
//  Tests
//
//  Created by Krunoslav Zaher on 11/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import "RXObjCRuntime+Testing.h"
#import <objc/runtime.h>
#import <objc/message.h>

static int32_t (^defaultImpl)(int32_t) = ^int32_t(int32_t a) {
    return 0;
};

#define A(...) [Arguments argumentsWithValues:@[__VA_ARGS__]]

@implementation RXObjCTestRuntime

+(id)castClosure:(void (^)(void))closure {
    return closure;
}

+(BOOL)isForwardingIMP:(IMP __nullable)implementation {
    return implementation == _objc_msgForward;
}

+(Class __nonnull)objCClass:(id __nonnull)target {
    return [target class];
}

@end

@implementation _TestSendMessage

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    [super forwardInvocation:anInvocation];
}

-(BOOL)respondsToSelector:(SEL)aSelector {
    return [super respondsToSelector:aSelector];
}

-(NSMethodSignature*)methodSignatureForSelector:(SEL)aSelector {
    return [super methodSignatureForSelector:aSelector];
}

-(void)first:(NSInteger)integer second:(NSInteger)second third:(float)third {
    
}

@end


#define IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName) _IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName,,)
#define _IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName, baseClassContent, subclassContent)                                                  \
/*##########################################################################################################################################*/ \
@interface SentMessageTestBase_ ## testName ()                                                                                                 \
@property (nonatomic, strong) NSMutableArray<Arguments *> *privateBaseMessages;                                                                \
@end                                                                                                                                           \
                                                                                                                                               \
@implementation SentMessageTestBase_ ## testName                                                                                               \
                                                                                                                                               \
-(NSArray *)baseMessages {                                                                                                                     \
    return self.privateBaseMessages;                                                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(instancetype)init {                                                                                                                          \
    self = [super init];                                                                                                                       \
    if (!self) return nil;                                                                                                                     \
                                                                                                                                               \
    self.privateBaseMessages = [[NSMutableArray alloc] init];                                                                                  \
                                                                                                                                               \
    return self;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
+(instancetype)createInstance {                                                                                                                \
    return [[self alloc] init];                                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledVoidToSay {                                                                                                               \
    [self.privateBaseMessages addObject:A()];                                                                                                  \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(id __nonnull)justCalledObjectToSay:(id __nonnull)value {                                                                                     \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value {                                                                                         \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value object:(id __nonnull)value1 {                                                             \
    [self.privateBaseMessages addObject:A(value, value1)];                                                                                     \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(Class __nonnull)justCalledClassToSay:(Class __nonnull)value {                                                                                \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClassToSay:(Class __nonnull)value {                                                                                       \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void (^ __nonnull)() )justCalledClosureToSay:(void (^ __nonnull)())value {                                                                   \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClosureToSay:(void (^ __nonnull)())value {                                                                                \
    [self.privateBaseMessages addObject:A(value)];                                                                                             \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(char)justCalledCharToSay:(char)value {                                                                                                       \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledCharToSay:(char)value {                                                                                                   \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(short)justCalledShortToSay:(short)value {                                                                                                    \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledShortToSay:(short)value {                                                                                                 \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(int)justCalledIntToSay:(int)value {                                                                                                          \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledIntToSay:(int)value {                                                                                                     \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(long)justCalledLongToSay:(long)value {                                                                                                       \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongToSay:(long)value {                                                                                                   \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(long long)justCalledLongLongToSay:(long long)value {                                                                                         \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongLongToSay:(long long)value {                                                                                          \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned char)justCalledUnsignedCharToSay:(unsigned char)value {                                                                             \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedCharToSay:(unsigned char)value {                                                                                  \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned short)justCalledUnsignedShortToSay:(unsigned short)value {                                                                          \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedShortToSay:(unsigned short)value {                                                                                \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned int)justCalledUnsignedIntToSay:(unsigned int)value {                                                                                \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedIntToSay:(unsigned int)value {                                                                                    \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long)justCalledUnsignedLongToSay:(unsigned long)value {                                                                             \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongToSay:(unsigned long)value {                                                                                  \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long long)justCalledUnsignedLongLongToSay:(unsigned long long)value {                                                               \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongLongToSay:(unsigned long long)value {                                                                         \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(float)justCalledFloatToSay:(float)value {                                                                                                    \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledFloatToSay:(float)value {                                                                                                 \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(double)justCalledDoubleToSay:(double)value {                                                                                                 \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledDoubleToSay:(double)value {                                                                                               \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(BOOL)justCalledBoolToSay:(BOOL)value {                                                                                                       \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledBoolToSay:(BOOL)value {                                                                                                   \
    [self.privateBaseMessages addObject:A(@(value))];                                                                                          \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(const char * __nonnull)justCalledConstCharToSay:(const char * __nonnull)value {                                                              \
    [self.privateBaseMessages addObject:A([NSValue valueWithPointer:value])];                                                                  \
    self.invokedMethod();                                                                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledConstCharToSay:(const char * __nonnull)value {                                                                            \
    [self.privateBaseMessages addObject:A([NSValue valueWithPointer:value])];                                                                  \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)justCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                         \
    [self.privateBaseMessages addObject:A([NSValue valueWithBytes:&value                                                                       \
                                                                        objCType:@encode(some_insanely_large_struct_t)])];                     \
    self.invokedMethod();                                                                                                                      \
    return value.a[0] + value.a[1] + value.a[2] + value.a[3] + value.a[4] + value.a[5] + value.a[6] + value.a[7];                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                          \
    [self.privateBaseMessages addObject:A([NSValue valueWithBytes:&value                                                                       \
                                                      objCType:@encode(some_insanely_large_struct_t)])];                                       \
    self.invokedMethod();                                                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)message_allSupportedParameters:(id __nullable)p1                                                                                   \
                                        p2:(Class __nullable)p2                                                                                \
                                        p3:(int32_t (^ __nullable)(int32_t))p3                                                                 \
                                        p4:(int8_t)p4                                                                                          \
                                        p5:(int16_t)p5                                                                                         \
                                        p6:(int32_t)p6                                                                                         \
                                        p7:(int64_t)p7                                                                                         \
                                        p8:(uint8_t)p8                                                                                         \
                                        p9:(uint16_t)p9                                                                                        \
                                       p10:(uint32_t)p10                                                                                       \
                                       p11:(uint64_t)p11                                                                                       \
                                       p12:(float)p12                                                                                          \
                                       p13:(double)p13                                                                                         \
                                       p14:(const int8_t * __nullable)p14                                                                      \
                                       p15:(int8_t * __nullable)p15                                                                            \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                 \
    [self.privateBaseMessages addObject:A(                                                                                                     \
        p1 ?: [NSNull null],                                                                                                                   \
        p2 ?: [NSNull null],                                                                                                                   \
        p3 ?: defaultImpl,                                                                                                                     \
        @(p4),                                                                                                                                 \
        @(p5),                                                                                                                                 \
        @(p6),                                                                                                                                 \
        @(p7),                                                                                                                                 \
        @(p8),                                                                                                                                 \
        @(p9),                                                                                                                                 \
        @(p10),                                                                                                                                \
        @(p11),                                                                                                                                \
        @(p12),                                                                                                                                \
        @(p13),                                                                                                                                \
        [NSValue valueWithPointer:p14],                                                                                                        \
        [NSValue valueWithPointer:p15],                                                                                                        \
        [NSValue valueWithBytes:&p16 objCType:@encode(some_insanely_large_struct_t)],                                                          \
    )];                                                                                                                                        \
    self.invokedMethod();                                                                                                                      \
    return -5;                                                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
                                                                                                                                               \
-(some_insanely_large_struct_t)hugeResult {                                                                                                    \
    some_insanely_large_struct_t huge = {};                                                                                                    \
    self.invokedMethod();                                                                                                                      \
    return huge;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
baseClassContent                                                                                                                               \
@end                                                                                                                                           \
                                                                                                                                               \
@interface SentMessageTest_ ## testName ()                                                                                                     \
@property (nonatomic, strong) NSMutableArray<Arguments *> *privateMessages;                                                                    \
@end                                                                                                                                           \
                                                                                                                                               \
@implementation SentMessageTest_ ## testName                                                                                                   \
                                                                                                                                               \
-(NSArray *)messages {                                                                                                                         \
    return self.privateMessages;                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(instancetype)init {                                                                                                                          \
    self = [super init];                                                                                                                       \
    if (!self) return nil;                                                                                                                     \
                                                                                                                                               \
    self.privateMessages = [[NSMutableArray alloc] init];                                                                                      \
                                                                                                                                               \
    return self;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledVoidToSay {                                                                                                               \
    [self.privateMessages addObject:A()];                                                                                                      \
    return [super voidJustCalledVoidToSay];                                                                                                    \
}                                                                                                                                              \
                                                                                                                                               \
-(id __nonnull)justCalledObjectToSay:(id __nonnull)value {                                                                                     \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super justCalledObjectToSay:value];                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value {                                                                                         \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super voidJustCalledObjectToSay:value];                                                                                            \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value object:(id __nonnull)value1 {                                                             \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super voidJustCalledObjectToSay:value object:value1];                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(Class __nonnull)justCalledClassToSay:(Class __nonnull)value {                                                                                \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super justCalledClassToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClassToSay:(Class __nonnull)value {                                                                                       \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super voidJustCalledClassToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(void (^ __nonnull)() )justCalledClosureToSay:(void (^ __nonnull)())value {                                                                   \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super justCalledClosureToSay:value];                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClosureToSay:(void (^ __nonnull)())value {                                                                                \
    [self.privateMessages addObject:A(value)];                                                                                                 \
    return [super voidJustCalledClosureToSay:value];                                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(char)justCalledCharToSay:(char)value {                                                                                                       \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledCharToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledCharToSay:(char)value {                                                                                                   \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledCharToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(short)justCalledShortToSay:(short)value {                                                                                                    \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledShortToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledShortToSay:(short)value {                                                                                                 \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledShortToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(int)justCalledIntToSay:(int)value {                                                                                                          \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledIntToSay:value];                                                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledIntToSay:(int)value {                                                                                                     \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledIntToSay:value];                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(long)justCalledLongToSay:(long)value {                                                                                                       \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledLongToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongToSay:(long)value {                                                                                                   \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledLongToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(long long)justCalledLongLongToSay:(long long)value {                                                                                         \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledLongLongToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongLongToSay:(long long)value {                                                                                          \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledLongLongToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned char)justCalledUnsignedCharToSay:(unsigned char)value {                                                                             \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledUnsignedCharToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedCharToSay:(unsigned char)value {                                                                                  \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledUnsignedCharToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned short)justCalledUnsignedShortToSay:(unsigned short)value {                                                                          \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledUnsignedShortToSay:value];                                                                                         \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedShortToSay:(unsigned short)value {                                                                                \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledUnsignedShortToSay:value];                                                                                     \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned int)justCalledUnsignedIntToSay:(unsigned int)value {                                                                                \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledUnsignedIntToSay:value];                                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedIntToSay:(unsigned int)value {                                                                                    \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledUnsignedIntToSay:value];                                                                                       \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long)justCalledUnsignedLongToSay:(unsigned long)value {                                                                             \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledUnsignedLongToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongToSay:(unsigned long)value {                                                                                  \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledUnsignedLongToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long long)justCalledUnsignedLongLongToSay:(unsigned long long)value {                                                               \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledUnsignedLongLongToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongLongToSay:(unsigned long long)value {                                                                         \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledUnsignedLongLongToSay:value];                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(float)justCalledFloatToSay:(float)value {                                                                                                    \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledFloatToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledFloatToSay:(float)value {                                                                                                 \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledFloatToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(double)justCalledDoubleToSay:(double)value {                                                                                                 \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledDoubleToSay:value];                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledDoubleToSay:(double)value {                                                                                               \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledDoubleToSay:value];                                                                                            \
}                                                                                                                                              \
                                                                                                                                               \
-(BOOL)justCalledBoolToSay:(BOOL)value {                                                                                                       \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super justCalledBoolToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledBoolToSay:(BOOL)value {                                                                                                   \
    [self.privateMessages addObject:A(@(value))];                                                                                              \
    return [super voidJustCalledBoolToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(const char * __nonnull)justCalledConstCharToSay:(const char * __nonnull)value {                                                              \
    [self.privateMessages addObject:A([NSValue valueWithPointer:value])];                                                                      \
    return [super justCalledConstCharToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledConstCharToSay:(const char * __nonnull)value {                                                                            \
    [self.privateMessages addObject:A([NSValue valueWithPointer:value])];                                                                      \
    return [super voidJustCalledConstCharToSay:value];                                                                                         \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)justCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                         \
    [self.privateMessages addObject:A([NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)])];                        \
    return [super justCalledLargeToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                          \
    [self.privateMessages addObject:A([NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)])];                        \
    return [super voidJustCalledLargeToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)message_allSupportedParameters:(id __nullable)p1                                                                                   \
                                        p2:(Class __nullable)p2                                                                                \
                                        p3:(int32_t (^ __nullable)(int32_t))p3                                                                 \
                                        p4:(int8_t)p4                                                                                          \
                                        p5:(int16_t)p5                                                                                         \
                                        p6:(int32_t)p6                                                                                         \
                                        p7:(int64_t)p7                                                                                         \
                                        p8:(uint8_t)p8                                                                                         \
                                        p9:(uint16_t)p9                                                                                        \
                                       p10:(uint32_t)p10                                                                                       \
                                       p11:(uint64_t)p11                                                                                       \
                                       p12:(float)p12                                                                                          \
                                       p13:(double)p13                                                                                         \
                                       p14:(const int8_t * __nullable)p14                                                                      \
                                       p15:(int8_t * __nullable)p15                                                                            \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                 \
    [self.privateMessages addObject:A(                                                                                                         \
        p1 ?: [NSNull null],                                                                                                                   \
        p2 ?: [NSNull null],                                                                                                                   \
        p3 ?: defaultImpl,                                                                                                                     \
        @(p4),                                                                                                                                 \
        @(p5),                                                                                                                                 \
        @(p6),                                                                                                                                 \
        @(p7),                                                                                                                                 \
        @(p8),                                                                                                                                 \
        @(p9),                                                                                                                                 \
        @(p10),                                                                                                                                \
        @(p11),                                                                                                                                \
        @(p12),                                                                                                                                \
        @(p13),                                                                                                                                \
        [NSValue valueWithPointer:p14],                                                                                                        \
        [NSValue valueWithPointer:p15],                                                                                                        \
        [NSValue valueWithBytes:&p16 objCType:@encode(some_insanely_large_struct_t)],                                                          \
    )];                                                                                                                                        \
    return [super message_allSupportedParameters:p1                                                                                            \
                                              p2:p2                                                                                            \
                                              p3:p3                                                                                            \
                                              p4:p4                                                                                            \
                                              p5:p5                                                                                            \
                                              p6:p6                                                                                            \
                                              p7:p7                                                                                            \
                                              p8:p8                                                                                            \
                                              p9:p9                                                                                            \
                                             p10:p10                                                                                           \
                                             p11:p11                                                                                           \
                                             p12:p12                                                                                           \
                                             p13:p13                                                                                           \
                                             p14:p14                                                                                           \
                                             p15:p15                                                                                           \
                                             p16:p16];                                                                                         \
}                                                                                                                                              \
                                                                                                                                               \
subclassContent                                                                                                                                \
@end

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(shared)

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(forwarding_basic)

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(interact_forwarding)

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_void)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_id)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_closure)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_int)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_long)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_char)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_id_id)

_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc,,)
_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc2,,)
_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_base, -(void)dealloc { rand(); }, )
_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_subclass, , -(void)dealloc { rand(); })
_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_base_subclass, -(void)dealloc { rand(); }, -(void)dealloc { rand(); })

_IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_int_base, -(void)optimized:(id)target { rand(); }, )

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(all_supported_types)


@implementation SentMessageTest_shared_mock_interceptor

-(Class __nonnull)class {
    return SentMessageTest_shared.class;
}

@end

@implementation Arguments

+(instancetype)argumentsWithValues:(NSArray *)values {
    Arguments *arguments = [[Arguments alloc] init];

    arguments->_values = [values copy];

    return arguments;
}

-(BOOL)isEqual:(Arguments *)object {
    if (object == self) {
        return YES;
    }

    if (object == nil) {
        return NO;
    }

    if ([self class] != [object class]) {
        return NO;
    }

    return [self.values isEqualToArray:object.values];
}

@end
