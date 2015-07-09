//
//  Disposable.h
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DisposeBlock)();

@interface RXDisposable : NSObject

@property (nonatomic, copy, readonly) DisposeBlock diposeBlock;

+(instancetype)disposableWithDisposeBlock:(DisposeBlock)disposeBlock;

-(void)dispose;

@end
