//
//  ObservableConvertibleType+SharedSequence.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension ObservableConvertibleType {
    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: Driving observable sequence.
     */
    public func asSharedSequence<SharingStrategy>(sharingStrategy: SharingStrategy.Type = SharingStrategy.self, onErrorJustReturn: Element) -> SharedSequence<SharingStrategy, Element> {
        let source = self
            .asSource()
            .observeOn(SharingStrategy.scheduler)
            .catchErrorJustReturn(onErrorJustReturn, Never.self)
            .ignoreCompleted(Never.self)
        return SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorDriveWith: SharedSequence that provides elements of the sequence in case of error.
     - returns: Driving observable sequence.
     */
    public func asSharedSequence<SharingStrategy>(sharingStrategy: SharingStrategy.Type = SharingStrategy.self, onErrorDriveWith: SharedSequence<SharingStrategy, Element>)
        -> SharedSequence<SharingStrategy, Element> {
        let source = self
            .asSource()
            .observeOn(SharingStrategy.scheduler)
            .catchError { (_: Error) -> ObservableSource<Element, Completed, Never> in
                return onErrorDriveWith.asSource().ignoreCompleted()
            }
            .ignoreCompleted(Never.self)
        return SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Driving observable sequence.
     */
    public func asSharedSequence<SharingStrategy>(sharingStrategy: SharingStrategy.Type = SharingStrategy.self, onErrorRecover: @escaping (_ error: Error) -> SharedSequence<SharingStrategy, Element>) -> SharedSequence<SharingStrategy, Element> {
        let source = self
            .asSource()
            .observeOn(SharingStrategy.scheduler)
            .catchError { error in
                return onErrorRecover(error).asSource().ignoreCompleted()
            }
            .ignoreCompleted(Never.self)
        return SharedSequence(source)
    }
}
