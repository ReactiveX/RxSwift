//
//  RXObjCRuntime+Testing.m
//  RxTests
//
//  Created by Krunoslav Zaher on 11/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import "RXObjCRuntime+Testing.h"
#import <objc/runtime.h>
#import <objc/message.h>

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

@interface A : NSObject @property(nonatomic, strong) NSString *a; -(void)ante; @end @implementation A -(void)ante { printf(""); } @end

#define IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName) _IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName,,)
#define _IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName, baseClassContent, subclassContent)                                                  \
/*##########################################################################################################################################*/ \
@implementation SentMessageTestBase_ ## testName                                                                                               \
                                                                                                                                               \
-(instancetype)init {                                                                                                                          \
    self = [super init];                                                                                                                       \
    if (!self) return nil;                                                                                                                     \
                                                                                                                                               \
    self.baseMessages = @[];                                                                                                                   \
                                                                                                                                               \
    return self;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
+(instancetype)createInstance {                                                                                                                \
    return [[self alloc] init];                                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledVoidToSay {                                                                                                               \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[]];                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(id __nonnull)justCalledObjectToSay:(id __nonnull)value {                                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value {                                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value object:(id __nonnull)value1 {                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value, value1]];                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(Class __nonnull)justCalledClassToSay:(Class __nonnull)value {                                                                                \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClassToSay:(Class __nonnull)value {                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void (^ __nonnull)() )justCalledClosureToSay:(void (^ __nonnull)())value {                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClosureToSay:(void (^ __nonnull)())value {                                                                                \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(char)justCalledCharToSay:(char)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledCharToSay:(char)value {                                                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(short)justCalledShortToSay:(short)value {                                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledShortToSay:(short)value {                                                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(int)justCalledIntToSay:(int)value {                                                                                                          \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledIntToSay:(int)value {                                                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(long)justCalledLongToSay:(long)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongToSay:(long)value {                                                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(long long)justCalledLongLongToSay:(long long)value {                                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongLongToSay:(long long)value {                                                                                          \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned char)justCalledUnsignedCharToSay:(unsigned char)value {                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedCharToSay:(unsigned char)value {                                                                                  \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned short)justCalledUnsignedShortToSay:(unsigned short)value {                                                                          \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedShortToSay:(unsigned short)value {                                                                                \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned int)justCalledUnsignedIntToSay:(unsigned int)value {                                                                                \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedIntToSay:(unsigned int)value {                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long)justCalledUnsignedLongToSay:(unsigned long)value {                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongToSay:(unsigned long)value {                                                                                  \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long long)justCalledUnsignedLongLongToSay:(unsigned long long)value {                                                               \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongLongToSay:(unsigned long long)value {                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(float)justCalledFloatToSay:(float)value {                                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledFloatToSay:(float)value {                                                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(double)justCalledDoubleToSay:(double)value {                                                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledDoubleToSay:(double)value {                                                                                               \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(BOOL)justCalledBoolToSay:(BOOL)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledBoolToSay:(BOOL)value {                                                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(const char * __nonnull)justCalledConstCharToSay:(const char * __nonnull)value {                                                              \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                           \
    return value;                                                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledConstCharToSay:(const char * __nonnull)value {                                                                            \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)justCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithBytes:&value                                                \
                                                                        objCType:@encode(some_insanely_large_struct_t)]]];                     \
    return value.a[0] + value.a[1] + value.a[2] + value.a[3] + value.a[4] + value.a[5] + value.a[6] + value.a[7];                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                          \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithBytes:&value                                                \
                                                      objCType:@encode(some_insanely_large_struct_t)]]];                                       \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)message_allSupportedParameters:(id __nonnull)p1                                                                                    \
                                        p2:(Class __nonnull)p2                                                                                 \
                                        p3:(int32_t (^ __nonnull)(int32_t))p3                                                                  \
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
                                       p14:(const int8_t * __nonnull)p14                                                                       \
                                       p15:(int8_t * __nonnull)p15                                                                             \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[                                                                              \
        p1,                                                                                                                                    \
        p2,                                                                                                                                    \
        p3,                                                                                                                                    \
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
    ]];                                                                                                                                        \
    return -5;                                                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
                                                                                                                                               \
-(some_insanely_large_struct_t)hugeResult {                                                                                                    \
    some_insanely_large_struct_t huge = {};                                                                                                    \
    return huge;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
baseClassContent                                                                                                                               \
@end                                                                                                                                           \
                                                                                                                                               \
@implementation SentMessageTest_ ## testName                                                                                                   \
                                                                                                                                               \
-(instancetype)init {                                                                                                                          \
    self = [super init];                                                                                                                       \
    if (!self) return nil;                                                                                                                     \
                                                                                                                                               \
    self.messages = @[];                                                                                                                       \
                                                                                                                                               \
    return self;                                                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledVoidToSay {                                                                                                               \
    self.messages = [self.messages arrayByAddingObject:@[]];                                                                                   \
    return [super voidJustCalledVoidToSay];                                                                                                    \
}                                                                                                                                              \
                                                                                                                                               \
-(id __nonnull)justCalledObjectToSay:(id __nonnull)value {                                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super justCalledObjectToSay:value];                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value {                                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super voidJustCalledObjectToSay:value];                                                                                            \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value object:(id __nonnull)value1 {                                                             \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super voidJustCalledObjectToSay:value object:value1];                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(Class __nonnull)justCalledClassToSay:(Class __nonnull)value {                                                                                \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super justCalledClassToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClassToSay:(Class __nonnull)value {                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super voidJustCalledClassToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(void (^ __nonnull)() )justCalledClosureToSay:(void (^ __nonnull)())value {                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super justCalledClosureToSay:value];                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledClosureToSay:(void (^ __nonnull)())value {                                                                                \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                              \
    return [super voidJustCalledClosureToSay:value];                                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(char)justCalledCharToSay:(char)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledCharToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledCharToSay:(char)value {                                                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledCharToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(short)justCalledShortToSay:(short)value {                                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledShortToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledShortToSay:(short)value {                                                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledShortToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(int)justCalledIntToSay:(int)value {                                                                                                          \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledIntToSay:value];                                                                                                   \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledIntToSay:(int)value {                                                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledIntToSay:value];                                                                                               \
}                                                                                                                                              \
                                                                                                                                               \
-(long)justCalledLongToSay:(long)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledLongToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongToSay:(long)value {                                                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledLongToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(long long)justCalledLongLongToSay:(long long)value {                                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledLongLongToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLongLongToSay:(long long)value {                                                                                          \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledLongLongToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned char)justCalledUnsignedCharToSay:(unsigned char)value {                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledUnsignedCharToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedCharToSay:(unsigned char)value {                                                                                  \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledUnsignedCharToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned short)justCalledUnsignedShortToSay:(unsigned short)value {                                                                          \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledUnsignedShortToSay:value];                                                                                         \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedShortToSay:(unsigned short)value {                                                                                \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledUnsignedShortToSay:value];                                                                                     \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned int)justCalledUnsignedIntToSay:(unsigned int)value {                                                                                \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledUnsignedIntToSay:value];                                                                                           \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedIntToSay:(unsigned int)value {                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledUnsignedIntToSay:value];                                                                                       \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long)justCalledUnsignedLongToSay:(unsigned long)value {                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledUnsignedLongToSay:value];                                                                                          \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongToSay:(unsigned long)value {                                                                                  \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledUnsignedLongToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(unsigned long long)justCalledUnsignedLongLongToSay:(unsigned long long)value {                                                               \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledUnsignedLongLongToSay:value];                                                                                      \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongLongToSay:(unsigned long long)value {                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledUnsignedLongLongToSay:value];                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(float)justCalledFloatToSay:(float)value {                                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledFloatToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledFloatToSay:(float)value {                                                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledFloatToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(double)justCalledDoubleToSay:(double)value {                                                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledDoubleToSay:value];                                                                                                \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledDoubleToSay:(double)value {                                                                                               \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledDoubleToSay:value];                                                                                            \
}                                                                                                                                              \
                                                                                                                                               \
-(BOOL)justCalledBoolToSay:(BOOL)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super justCalledBoolToSay:value];                                                                                                  \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledBoolToSay:(BOOL)value {                                                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                           \
    return [super voidJustCalledBoolToSay:value];                                                                                              \
}                                                                                                                                              \
                                                                                                                                               \
-(const char * __nonnull)justCalledConstCharToSay:(const char * __nonnull)value {                                                              \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                                   \
    return [super justCalledConstCharToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledConstCharToSay:(const char * __nonnull)value {                                                                            \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                                   \
    return [super voidJustCalledConstCharToSay:value];                                                                                         \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)justCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]];     \
    return [super justCalledLargeToSay:value];                                                                                                 \
}                                                                                                                                              \
                                                                                                                                               \
-(void)voidJustCalledLargeToSay:(some_insanely_large_struct_t)value {                                                                          \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]];     \
    return [super voidJustCalledLargeToSay:value];                                                                                             \
}                                                                                                                                              \
                                                                                                                                               \
-(NSInteger)message_allSupportedParameters:(id __nonnull)p1                                                                                    \
                                        p2:(Class __nonnull)p2                                                                                 \
                                        p3:(int32_t (^ __nonnull)(int32_t))p3                                                                  \
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
                                       p14:(const int8_t * __nonnull)p14                                                                       \
                                       p15:(int8_t * __nonnull)p15                                                                             \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[                                                                                      \
        p1,                                                                                                                                    \
        p2,                                                                                                                                    \
        p3,                                                                                                                                    \
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
    ]];                                                                                                                                        \
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
