//
//  RXObjCRuntime+Testing.h
//  Tests
//
//  Created by Krunoslav Zaher on 11/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <RxCocoa/RxCocoa.h>

#if TRACE_RESOURCES
NSInteger RX_number_of_dynamic_subclasses(void);
NSInteger RX_number_of_forwarding_enabled_classes(void);
NSInteger RX_number_of_intercepting_classes(void);
NSInteger RX_number_of_forwarded_methods(void);
NSInteger RX_number_of_swizzled_methods(void);
#endif

@protocol SentMessageTestClassCreationProtocol<NSObject>
+(instancetype __nonnull)createInstance;

@property (nonatomic, copy) void (^ __nonnull invokedMethod)(void);
@end

@interface RXObjCTestRuntime : NSObject

+(id __nonnull)castClosure:(void (^ __nonnull)(void))closure;
+(BOOL)isForwardingIMP:(IMP __nullable)implementation;
+(Class __nonnull)objCClass:(id __nonnull)target;

@end

@interface _TestSendMessage : NSObject

@end

@interface Arguments:  NSObject

@property(nonatomic, copy, readonly, nonnull) NSArray *values;

+(instancetype __nonnull)argumentsWithValues:(NSArray* __nonnull)values;

@end

typedef struct some_insanely_large_struct {
    int a[8];
    const char * __nullable some_large_text; //:)
    struct some_insanely_large_struct * __nullable next;
} some_insanely_large_struct_t;

#define _DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(testName, baseContent, subclassContent)                                                         \
/*##########################################################################################################################################*/ \
@interface SentMessageTestBase_ ## testName : NSObject<SentMessageTestClassCreationProtocol> { }                                               \
                                                                                                                                               \
@property (nonatomic, strong, readonly) NSArray<Arguments *> * __nonnull baseMessages;                                                         \
@property (nonatomic, copy) void (^ __nonnull invokedMethod)(void);                                                                                \
                                                                                                                                               \
-(void)voidJustCalledVoidToSay;                                                                                                                \
                                                                                                                                               \
-(id __nonnull)justCalledObjectToSay:(id __nonnull)value;                                                                                      \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value;                                                                                          \
                                                                                                                                               \
-(void)voidJustCalledObjectToSay:(id __nonnull)value object:(id __nonnull)value1;                                                              \
                                                                                                                                               \
-(Class __nonnull)justCalledClassToSay:(Class __nonnull)value;                                                                                 \
                                                                                                                                               \
-(void)voidJustCalledClassToSay:(Class __nonnull)value;                                                                                        \
                                                                                                                                               \
-(void (^ __nonnull)(void) )justCalledClosureToSay:(void (^ __nonnull)(void))value;                                                                    \
                                                                                                                                               \
-(void)voidJustCalledClosureToSay:(void (^ __nonnull)(void))value;                                                                                 \
                                                                                                                                               \
-(char)justCalledCharToSay:(char)value;                                                                                                        \
                                                                                                                                               \
-(void)voidJustCalledCharToSay:(char)value;                                                                                                    \
                                                                                                                                               \
-(short)justCalledShortToSay:(short)value;                                                                                                     \
                                                                                                                                               \
-(void)voidJustCalledShortToSay:(short)value;                                                                                                  \
                                                                                                                                               \
-(int)justCalledIntToSay:(int)value;                                                                                                           \
                                                                                                                                               \
-(void)voidJustCalledIntToSay:(int)value;                                                                                                      \
                                                                                                                                               \
-(long)justCalledLongToSay:(long)value;                                                                                                        \
                                                                                                                                               \
-(void)voidJustCalledLongToSay:(long)value;                                                                                                    \
                                                                                                                                               \
-(long long)justCalledLongLongToSay:(long long)value;                                                                                          \
                                                                                                                                               \
-(void)voidJustCalledLongLongToSay:(long long)value;                                                                                           \
                                                                                                                                               \
-(unsigned char)justCalledUnsignedCharToSay:(unsigned char)value;                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedCharToSay:(unsigned char)value;                                                                                   \
                                                                                                                                               \
-(unsigned short)justCalledUnsignedShortToSay:(unsigned short)value;                                                                           \
                                                                                                                                               \
-(void)voidJustCalledUnsignedShortToSay:(unsigned short)value;                                                                                 \
                                                                                                                                               \
-(unsigned int)justCalledUnsignedIntToSay:(unsigned int)value;                                                                                 \
                                                                                                                                               \
-(void)voidJustCalledUnsignedIntToSay:(unsigned int)value;                                                                                     \
                                                                                                                                               \
-(unsigned long)justCalledUnsignedLongToSay:(unsigned long)value;                                                                              \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongToSay:(unsigned long)value;                                                                                   \
                                                                                                                                               \
-(unsigned long long)justCalledUnsignedLongLongToSay:(unsigned long long)value;                                                                \
                                                                                                                                               \
-(void)voidJustCalledUnsignedLongLongToSay:(unsigned long long)value;                                                                          \
                                                                                                                                               \
-(float)justCalledFloatToSay:(float)value;                                                                                                     \
                                                                                                                                               \
-(void)voidJustCalledFloatToSay:(float)value;                                                                                                  \
                                                                                                                                               \
-(double)justCalledDoubleToSay:(double)value;                                                                                                  \
                                                                                                                                               \
-(void)voidJustCalledDoubleToSay:(double)value;                                                                                                \
                                                                                                                                               \
-(BOOL)justCalledBoolToSay:(BOOL)value;                                                                                                        \
                                                                                                                                               \
-(void)voidJustCalledBoolToSay:(BOOL)value;                                                                                                    \
                                                                                                                                               \
-(NSInteger)justCalledLargeToSay:(some_insanely_large_struct_t)value;                                                                          \
                                                                                                                                               \
-(void)voidJustCalledLargeToSay:(some_insanely_large_struct_t)value;                                                                           \
                                                                                                                                               \
-(const char * __nonnull)justCalledConstCharToSay:(const char * __nonnull)value;                                                               \
                                                                                                                                               \
-(void)voidJustCalledConstCharToSay:(const char * __nonnull)value;                                                                             \
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
                                        p10:(uint32_t)p10                                                                                      \
                                        p11:(uint64_t)p11                                                                                      \
                                        p12:(float)p12                                                                                         \
                                        p13:(double)p13                                                                                        \
                                        p14:(const int8_t * __nullable)p14                                                                     \
                                        p15:(int8_t * __nullable)p15                                                                           \
                                        p16:(some_insanely_large_struct_t)p16;                                                                 \
                                                                                                                                               \
-(some_insanely_large_struct_t)hugeResult;                                                                                                     \
                                                                                                                                               \
baseContent                                                                                                                                    \
@end                                                                                                                                           \
                                                                                                                                               \
@interface SentMessageTest_ ## testName : SentMessageTestBase_ ## testName<SentMessageTestClassCreationProtocol> { }                           \
                                                                                                                                               \
@property (nonatomic, strong, readonly) NSArray<Arguments *> * __nonnull messages;                                                             \
                                                                                                                                               \
subclassContent                                                                                                                                \
@end

#define DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(testName) _DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(testName,,)

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(shared)

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(forwarding_basic)

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(interact_forwarding)

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_void)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_id)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_closure)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_int)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_long)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_char)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_id_id)

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc2)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_base)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_subclass)
DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(dealloc_base_subclass)

_DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(optimized_int_base, -(void)optimized:(id __nonnull)target;, )

DECLARE_OBSERVING_CLASS_PAIR_FOR_TEST(all_supported_types)

@interface SentMessageTest_shared_mock_interceptor : SentMessageTest_shared
@end
