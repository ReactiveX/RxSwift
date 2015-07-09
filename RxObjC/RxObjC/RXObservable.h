//
//  Observable.h
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^RxMap)(id element);
typedef BOOL (^RxFilter)(id element);

@class RXDisposable;
@class RXObserver;

typedef RXDisposable *(^RXObservableSubscribe)(RXObserver *observer);

@interface RXObservable : NSObject

@property (nonatomic, strong) id swiftObservable;

-(RXDisposable*)subscribe:(RXObserver*)observer;

+(RXObservable*)createObservable:(RXObservableSubscribe)didSubscribe;

+(instancetype)_createWithSwiftObservable:(id)observable;

@property (nonatomic, readonly, copy) RXObservable * (^map)(RxMap);
@property (nonatomic, readonly, copy) RXObservable * (^filter)(RxFilter);

@property (nonatomic, readonly, copy) RXDisposable * (^subscribeNext)(ObserverOnNext);
@property (nonatomic, readonly, copy) RXDisposable * (^subscribe)(ObserverOnNext);

@end
