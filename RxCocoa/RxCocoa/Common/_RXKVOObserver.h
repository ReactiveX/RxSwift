//
//  _RXKVOObserver.h
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/11/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^KVOCallback)(id);

// Exists because if written in Swift, reading unowned is disabled during dealloc process
@interface _RXKVOObserver : NSObject

-(instancetype)initWithTarget:(id)target
                 retainTarget:(BOOL)retainTarget
                      keyPath:(NSString*)keyPath
                      options:(NSKeyValueObservingOptions)options
                     callback:(KVOCallback)callback;

-(void)dispose;

@end
