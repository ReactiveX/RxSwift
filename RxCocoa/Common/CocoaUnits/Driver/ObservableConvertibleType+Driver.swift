//
//  ObservableConvertibleType+Driver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableConvertibleType {
    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorJustReturn onErrorJustReturn: E) -> Driver<E> {
        let source = self
            .asObservable()
            .catchErrorJustReturn(onErrorJustReturn)
            .observeOn(MainScheduler.sharedInstance)
        return Driver(source)
    }
    
    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorDriveWith: Driver that continues to drive the sequence in case of error.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorDriveWith onErrorDriveWith: Driver<E>) -> Driver<E> {
        let source = self
            .asObservable()
            .catchError { _ in
                onErrorDriveWith.asObservable()
            }
            .observeOn(MainScheduler.sharedInstance)
        return Driver(source)
    }

    /**
    Converts anything convertible to `Observable` to `Driver` unit.
    
    - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
    - returns: Driving observable sequence.
    */
    public func asDriver(onErrorRecover onErrorRecover: (error: ErrorType) -> Driver<E>) -> Driver<E> {
        let source = self
            .asObservable()
            .catchError { error in
                onErrorRecover(error: error).asObservable()
            }
            .observeOn(MainScheduler.sharedInstance)
        return Driver(source)
    }
}