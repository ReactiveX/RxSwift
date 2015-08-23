//
//  _RXSwizzling.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

#if !DISABLE_SWIZZLING

extern void * const RXDeallocatingAssociatedAction;

@protocol RXDeallocating

-(void)deallocating;

@end

void RX_ensure_deallocating_swizzled(Class targetClass);

#endif