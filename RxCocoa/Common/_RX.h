//
//  _RX.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

#if DEBUG
#   define DLOG(...)  NSLog(__VA_ARGS__)
#else
#   define DLOG(...)
#endif


NSArray * __nonnull RX_extract_arguments(NSInvocation * __nonnull invocation);
BOOL RX_is_method_with_description_void(struct objc_method_description method);
BOOL RX_is_method_void(NSInvocation * __nonnull invocation);

#define SEL_VALUE(x)    [NSValue valueWithPointer:(x)]
#define CLASS_VALUE(x)  [NSValue valueWithNonretainedObject:(x)]
