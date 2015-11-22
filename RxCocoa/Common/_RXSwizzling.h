//
//  _RXSwizzling.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !DISABLE_SWIZZLING

SEL _Nonnull RX_selector(SEL _Nonnull selector);
void * __nonnull RX_reference_from_selector(SEL __nonnull selector);

@protocol RXMessageSentObserver

-(void)messageSentWithParameters:(NSArray* __nonnull)parameters;

@end

void RX_ensure_observing(id __nonnull target, SEL __nonnull selector);

#endif