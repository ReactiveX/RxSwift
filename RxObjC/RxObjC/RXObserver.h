//
//  Observer.h
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^ObserverOnNext)(id element);
typedef void (^ObserverOnError)(NSError *error);
typedef void (^ObserverOnCompleted)();

@interface RXObserver : NSObject

- (void)onNext:(id)element;

- (void)onError:(NSError *)error;

- (void)onCompleted;

+ (instancetype)observerWithOnNext:(ObserverOnNext)onNext
                           onError:(ObserverOnError)onError
                       onCompleted:(ObserverOnCompleted)onCompleted;

@end
