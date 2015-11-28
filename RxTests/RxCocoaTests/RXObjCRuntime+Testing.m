//
//  RXObjCRuntime+Testing.m
//  RxTests
//
//  Created by Krunoslav Zaher on 11/25/15.
//
//

#import "RXObjCRuntime+Testing.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation RXObjCTestRuntime

+(id)castClosure:(int (^)(int))closure {
    return closure;
}

+(BOOL)isForwardingIMP:(IMP __nullable)implementation {
    return implementation == _objc_msgForward;
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

#define IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(testName)                                                                                          \
@implementation SendMessageTestBase_ ## testName                                                                                                   \
                                                                                                                                                   \
-(instancetype)init {                                                                                                                              \
    self = [super init];                                                                                                                           \
    if (!self) return nil;                                                                                                                         \
                                                                                                                                                   \
    self.baseMessages = @[];                                                                                                                       \
                                                                                                                                                   \
    return self;                                                                                                                                   \
}                                                                                                                                                  \
                                                                                                                                                   \
-(id __nonnull)justCalledToSayObject:(id __nonnull)value {                                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayObject:(id __nonnull)value {                                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
}                                                                                                                                                  \
                                                                                                                                                   \
-(Class __nonnull)justCalledToSayClass:(Class __nonnull)value {                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayClass:(Class __nonnull)value {                                                                                           \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void (^ __nonnull)() )justCalledToSayClosure:(void (^ __nonnull)())value {                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayClosure:(void (^ __nonnull)())value {                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[value]];                                                                          \
}                                                                                                                                                  \
                                                                                                                                                   \
-(char)justCalledToSayChar:(char)value {                                                                                                           \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayChar:(char)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(short)justCalledToSayShort:(short)value {                                                                                                        \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayShort:(short)value {                                                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(int)justCalledToSayInt:(int)value {                                                                                                              \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayInt:(int)value {                                                                                                         \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(long)justCalledToSayLong:(long)value {                                                                                                           \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLong:(long)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(long long)justCalledToSayLongLong:(long long)value {                                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLongLong:(long long)value {                                                                                              \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned char)justCalledToSayUnsignedChar:(unsigned char)value {                                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedChar:(unsigned char)value {                                                                                      \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned short)justCalledToSayUnsignedShort:(unsigned short)value {                                                                              \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedShort:(unsigned short)value {                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned int)justCalledToSayUnsignedInt:(unsigned int)value {                                                                                    \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedInt:(unsigned int)value {                                                                                        \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned long)justCalledToSayUnsignedLong:(unsigned long)value {                                                                                 \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedLong:(unsigned long)value {                                                                                      \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned long long)justCalledToSayUnsignedLongLong:(unsigned long long)value {                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedLongLong:(unsigned long long)value {                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(float)justCalledToSayFloat:(float)value {                                                                                                        \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayFloat:(float)value {                                                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(double)justCalledToSayDouble:(double)value {                                                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayDouble:(double)value {                                                                                                   \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(BOOL)justCalledToSayBool:(BOOL)value {                                                                                                           \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayBool:(BOOL)value {                                                                                                       \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[@(value)]];                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(const char * __nonnull)justCalledToSayConstChar:(const char * __nonnull)value {                                                                  \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                               \
    return value;                                                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayConstChar:(const char * __nonnull)value {                                                                                \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(NSInteger)justCalledToSayLarge:(some_insanely_large_struct_t)value {                                                                             \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]]; \
    return value.a[0] + value.a[1] + value.a[2] + value.a[3] + value.a[4] + value.a[5] + value.a[6] + value.a[7];                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLarge:(some_insanely_large_struct_t)value {                                                                              \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]]; \
}                                                                                                                                                  \
                                                                                                                                                   \
-(NSInteger)message_allSupportedParameters:(id __nonnull)p1                                                                                        \
                                        p2:(Class __nonnull)p2                                                                                     \
                                        p3:(int32_t (^ __nonnull)(int32_t))p3                                                                      \
                                        p4:(int8_t)p4                                                                                              \
                                        p5:(int16_t)p5                                                                                             \
                                        p6:(int32_t)p6                                                                                             \
                                        p7:(int64_t)p7                                                                                             \
                                        p8:(uint8_t)p8                                                                                             \
                                        p9:(uint16_t)p9                                                                                            \
                                       p10:(uint32_t)p10                                                                                           \
                                       p11:(uint64_t)p11                                                                                           \
                                       p12:(float)p12                                                                                              \
                                       p13:(double)p13                                                                                             \
                                       p14:(const int8_t * __nonnull)p14                                                                           \
                                       p15:(int8_t * __nonnull)p15                                                                                 \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                     \
    self.baseMessages = [self.baseMessages arrayByAddingObject:@[                                                                                  \
        p1,                                                                                                                                        \
        p2,                                                                                                                                        \
        p3,                                                                                                                                        \
        @(p4),                                                                                                                                     \
        @(p5),                                                                                                                                     \
        @(p6),                                                                                                                                     \
        @(p7),                                                                                                                                     \
        @(p8),                                                                                                                                     \
        @(p9),                                                                                                                                     \
        @(p10),                                                                                                                                    \
        @(p11),                                                                                                                                    \
        @(p12),                                                                                                                                    \
        @(p13),                                                                                                                                    \
        [NSValue valueWithPointer:p14],                                                                                                            \
        [NSValue valueWithPointer:p15],                                                                                                            \
        [NSValue valueWithBytes:&p16 objCType:@encode(some_insanely_large_struct_t)],                                                              \
    ]];                                                                                                                                            \
    return -5;                                                                                                                                     \
}                                                                                                                                                  \
                                                                                                                                                   \
                                                                                                                                                   \
@end                                                                                                                                               \
                                                                                                                                                   \
@implementation SendMessageTest_ ## testName                                                                                                       \
                                                                                                                                                   \
-(instancetype)init {                                                                                                                              \
    self = [super init];                                                                                                                           \
    if (!self) return nil;                                                                                                                         \
                                                                                                                                                   \
    self.messages = @[];                                                                                                                           \
                                                                                                                                                   \
    return self;                                                                                                                                   \
}                                                                                                                                                  \
                                                                                                                                                   \
-(id __nonnull)justCalledToSayObject:(id __nonnull)value {                                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
    return [super justCalledToSayObject:value];                                                                                                    \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayObject:(id __nonnull)value {                                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(Class __nonnull)justCalledToSayClass:(Class __nonnull)value {                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
    return [super justCalledToSayClass:value];                                                                                                     \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayClass:(Class __nonnull)value {                                                                                           \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void (^ __nonnull)() )justCalledToSayClosure:(void (^ __nonnull)())value {                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
    return [super justCalledToSayClosure:value];                                                                                                   \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayClosure:(void (^ __nonnull)())value {                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[value]];                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(char)justCalledToSayChar:(char)value {                                                                                                           \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayChar:value];                                                                                                      \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayChar:(char)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(short)justCalledToSayShort:(short)value {                                                                                                        \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayShort:value];                                                                                                     \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayShort:(short)value {                                                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(int)justCalledToSayInt:(int)value {                                                                                                              \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayInt:value];                                                                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayInt:(int)value {                                                                                                         \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(long)justCalledToSayLong:(long)value {                                                                                                           \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayLong:value];                                                                                                      \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLong:(long)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(long long)justCalledToSayLongLong:(long long)value {                                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayLongLong:value];                                                                                                  \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLongLong:(long long)value {                                                                                              \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned char)justCalledToSayUnsignedChar:(unsigned char)value {                                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayUnsignedChar:value];                                                                                              \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedChar:(unsigned char)value {                                                                                      \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned short)justCalledToSayUnsignedShort:(unsigned short)value {                                                                              \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayUnsignedShort:value];                                                                                             \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedShort:(unsigned short)value {                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned int)justCalledToSayUnsignedInt:(unsigned int)value {                                                                                    \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayUnsignedInt:value];                                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedInt:(unsigned int)value {                                                                                        \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned long)justCalledToSayUnsignedLong:(unsigned long)value {                                                                                 \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayUnsignedLong:value];                                                                                              \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedLong:(unsigned long)value {                                                                                      \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(unsigned long long)justCalledToSayUnsignedLongLong:(unsigned long long)value {                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayUnsignedLongLong:value];                                                                                          \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayUnsignedLongLong:(unsigned long long)value {                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(float)justCalledToSayFloat:(float)value {                                                                                                        \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayFloat:value];                                                                                                     \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayFloat:(float)value {                                                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(double)justCalledToSayDouble:(double)value {                                                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayDouble:value];                                                                                                    \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayDouble:(double)value {                                                                                                   \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(BOOL)justCalledToSayBool:(BOOL)value {                                                                                                           \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
    return [super justCalledToSayBool:value];                                                                                                      \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayBool:(BOOL)value {                                                                                                       \
    self.messages = [self.messages arrayByAddingObject:@[@(value)]];                                                                               \
}                                                                                                                                                  \
                                                                                                                                                   \
-(const char * __nonnull)justCalledToSayConstChar:(const char * __nonnull)value {                                                                  \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                                       \
    return [super justCalledToSayConstChar:value];                                                                                                 \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayConstChar:(const char * __nonnull)value {                                                                                \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithPointer:value]]];                                                       \
}                                                                                                                                                  \
                                                                                                                                                   \
-(NSInteger)justCalledToSayLarge:(some_insanely_large_struct_t)value {                                                                             \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]];         \
    return [super justCalledToSayLarge:value];                                                                                                     \
}                                                                                                                                                  \
                                                                                                                                                   \
-(void)voidJustCalledToSayLarge:(some_insanely_large_struct_t)value {                                                                              \
    self.messages = [self.messages arrayByAddingObject:@[[NSValue valueWithBytes:&value objCType:@encode(some_insanely_large_struct_t)]]];         \
}                                                                                                                                                  \
                                                                                                                                                   \
-(NSInteger)message_allSupportedParameters:(id __nonnull)p1                                                                                        \
                                        p2:(Class __nonnull)p2                                                                                     \
                                        p3:(int32_t (^ __nonnull)(int32_t))p3                                                                      \
                                        p4:(int8_t)p4                                                                                              \
                                        p5:(int16_t)p5                                                                                             \
                                        p6:(int32_t)p6                                                                                             \
                                        p7:(int64_t)p7                                                                                             \
                                        p8:(uint8_t)p8                                                                                             \
                                        p9:(uint16_t)p9                                                                                            \
                                       p10:(uint32_t)p10                                                                                           \
                                       p11:(uint64_t)p11                                                                                           \
                                       p12:(float)p12                                                                                              \
                                       p13:(double)p13                                                                                             \
                                       p14:(const int8_t * __nonnull)p14                                                                           \
                                       p15:(int8_t * __nonnull)p15                                                                                 \
                                       p16:(some_insanely_large_struct_t)p16 {                                                                     \
    self.messages = [self.messages arrayByAddingObject:@[                                                                                          \
        p1,                                                                                                                                        \
        p2,                                                                                                                                        \
        p3,                                                                                                                                        \
        @(p4),                                                                                                                                     \
        @(p5),                                                                                                                                     \
        @(p6),                                                                                                                                     \
        @(p7),                                                                                                                                     \
        @(p8),                                                                                                                                     \
        @(p9),                                                                                                                                     \
        @(p10),                                                                                                                                    \
        @(p11),                                                                                                                                    \
        @(p12),                                                                                                                                    \
        @(p13),                                                                                                                                    \
        [NSValue valueWithPointer:p14],                                                                                                            \
        [NSValue valueWithPointer:p15],                                                                                                            \
        [NSValue valueWithBytes:&p16 objCType:@encode(some_insanely_large_struct_t)],                                                              \
    ]];                                                                                                                                            \
    return [super message_allSupportedParameters:p1                                                                                                \
                                              p2:p2                                                                                                \
                                              p3:p3                                                                                                \
                                              p4:p4                                                                                                \
                                              p5:p5                                                                                                \
                                              p6:p6                                                                                                \
                                              p7:p7                                                                                                \
                                              p8:p8                                                                                                \
                                              p9:p9                                                                                                \
                                             p10:p10                                                                                               \
                                             p11:p11                                                                                               \
                                             p12:p12                                                                                               \
                                             p13:p13                                                                                               \
                                             p14:p14                                                                                               \
                                             p15:p15                                                                                               \
                                             p16:p16];                                                                                             \
}                                                                                                                                                  \
                                                                                                                                                   \
@end


IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(acting_forwarding)

IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(forwarding_basic)
IMPLEMENT_OBSERVING_CLASS_PAIR_FOR_TEST(generating_dynamic_class)