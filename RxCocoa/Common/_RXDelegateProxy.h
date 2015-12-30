//
//  _RXDelegateProxy.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface _RXDelegateProxy : NSObject

@property (nonatomic, assign, readonly) id _forwardToDelegate;

-(void)_setForwardToDelegate:(id)forwardToDelegate retainDelegate:(BOOL)retainDelegate;

-(BOOL)hasWiredImplementationForSelector:(SEL)selector;

-(void)interceptedSelector:(SEL)selector withArguments:(NSArray*)arguments;

@end
