//
//  Observable+Concurrency.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// observeOnSingle

extension ObservableType {
    // `observeSingleOn` assumes that observed sequence will have one element
    // and in cases it has more than one element it will throw an exception.
    //
    // Most common use case for `observeSingleOn` would be to execute some work on background thread
    // and return result to main thread.
    //
    // This is a performance gain considering general case.
    public func observeSingleOn(scheduler: ImmediateScheduler)
        -> Observable<E> {
        return ObserveSingleOn(source: self.asObservable(), scheduler: scheduler)
    }
}

// observeOn

extension ObservableType {

    public func observeOn(scheduler: ImmediateScheduler)
        -> Observable<E> {
        if let scheduler = scheduler as? SerialDispatchQueueScheduler {
            return ObserveOnSerialDispatchQueue(source: self.asObservable(), scheduler: scheduler)
        }
        else {
            return ObserveOn(source: self.asObservable(), scheduler: scheduler)
        }
    }
}

// subscribeOn

extension ObservableType {
    public func subscribeOn(scheduler: ImmediateScheduler)
        -> Observable<E> {
        return SubscribeOn(source: self.asObservable(), scheduler: scheduler)
    }
}