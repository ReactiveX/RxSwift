//
//  Disposable.m
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import "RXDisposable.h"

@interface RXDisposable()

@property (nonatomic, copy) DisposeBlock disposeBlock;

@end

@implementation RXDisposable

+(instancetype)disposableWithDisposeBlock:(DisposeBlock)disposeBlock {
    RXDisposable *disposable = [[super alloc] init];
    
    if (!disposable) return nil;
    
    disposable.disposeBlock = disposeBlock;
    
    return disposable;
}

-(void)dispose {
    self.disposeBlock();
}

@end
