//
//  RXObjCRuntime.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !DISABLE_SWIZZLING

/**
 This file is part of RX private API
 */

SEL _Nonnull RX_selector(SEL _Nonnull selector);

void * __nonnull RX_reference_from_selector(SEL __nonnull selector);

@protocol RXSwizzlingObserver

-(void)methodForSelectorDoesntExist;
-(void)errorDuringSwizzling;

@end

@protocol RXMessageSentObserver <RXSwizzlingObserver>

-(void)messageSentWithParameters:(NSArray* __nonnull)parameters;

@end

@protocol RXDeallocatingObserver <RXSwizzlingObserver>

-(void)deallocating;

@end

void RX_ensure_observing(id __nonnull target, SEL __nonnull selector);

NSArray * __nonnull RX_extract_arguments(NSInvocation * __nonnull invocation);

BOOL RX_is_method_with_description_void(struct objc_method_description method);

BOOL RX_is_method_signature_void(NSMethodSignature * __nonnull methodSignature);

#if DEBUG
NSInteger RX_number_of_dynamic_subclasses();
NSInteger RX_number_of_forwarding_enabled_classes();
NSInteger RX_number_of_intercepting_classes();
NSInteger RX_number_of_forwarded_methods();
NSInteger RX_number_of_swizzled_methods();
#endif

#endif