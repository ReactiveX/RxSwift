//
//  RXObservable.m
//  RxObjC
//
//  Created by Krunoslav Zaher on 7/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#import <RxObjC/RxObjC.h>

@interface RXObservable()

@end

@implementation RXObservable

-(RXDisposable*)subscribe:(RXObserver *)observer {
    return nil;
}

+(RXObservable*)createObservable:(RXObservableSubscribe)didSubscribe {
    return [self createRxObservable:didSubscribe];
}

+(instancetype)_createWithSwiftObservable:(id)swiftObservable {
    RXObservable *observable = [[self alloc] init];
    observable.swiftObservable = swiftObservable;
    return observable;
}

-(RXObservable *(^)(RxMap transform))map {
    return self._map;
}

-(RXObservable *(^)(RxFilter transform))filter:(RxFilter)transform {
    return self._filter;
}

-(RXDisposable *(^)(ObserverOnNext))subscribeNext {
    return self._subscribeNext;
}

-(RXDisposable *(^)(ObserverOnNext))subscribe {
    return self._subscribe;
}

@end
