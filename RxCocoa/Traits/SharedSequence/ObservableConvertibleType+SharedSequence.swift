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
    public func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorJustReturn: Element) -> SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observe(on:S.scheduler)
            .catchAndReturn(onErrorJustReturn)
        return SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorDriveWith: SharedSequence that provides elements of the sequence in case of error.
     - returns: Driving observable sequence.
     */
    public func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorDriveWith: SharedSequence<S, Element>) -> SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observe(on:S.scheduler)
            .catch { _ in
                onErrorDriveWith.asObservable()
            }
        return SharedSequence(source)
    }

    /**
     Converts anything convertible to `Observable` to `SharedSequence` unit.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Driving observable sequence.
     */
    public func asSharedSequence<S>(sharingStrategy: S.Type = S.self, onErrorRecover: @escaping (_ error: Swift.Error) -> SharedSequence<S, Element>) -> SharedSequence<S, Element> {
        let source = self
            .asObservable()
            .observe(on:S.scheduler)
            .catch { error in
                onErrorRecover(error).asObservable()
            }
        return SharedSequence(source)
    }
}
