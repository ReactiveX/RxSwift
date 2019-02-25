//
//  ObservableConvertibleType+Signal.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension ObservableConvertibleType {
    /**
     Converts observable sequence to `Signal` trait.

     - parameter onErrorJustReturn: Element to return in case of error and after that complete the sequence.
     - returns: Signal trait.
     */
    public func asSignal(onErrorJustReturn: Element) -> Signal<Element> {
        let source = self
            .asSource()
            .observeOn(SignalSharingStrategy.scheduler)
            .catchErrorJustReturn(onErrorJustReturn, Never.self)
            .ignoreCompleted(Never.self)
        return Signal(source)
    }

    /**
     Converts observable sequence to `Driver` trait.

     - parameter onErrorDriveWith: Driver that continues to drive the sequence in case of error.
     - returns: Signal trait.
     */
    public func asSignal(onErrorSignalWith: Signal<Element>) -> Signal<Element> {
        let source = self
            .asSource()
            .observeOn(SignalSharingStrategy.scheduler)
            .catchError { (_: Error) -> ObservableSource<Element, Completed, Never> in
                return onErrorSignalWith.asSource().ignoreCompleted()
            }
            .ignoreCompleted(Never.self)
        return Signal(source)
    }

    /**
     Converts observable sequence to `Driver` trait.

     - parameter onErrorRecover: Calculates driver that continues to drive the sequence in case of error.
     - returns: Signal trait.
     */
    public func asSignal(onErrorRecover: @escaping (_ error: Error) -> Signal<Element>) -> Signal<Element> {
        let source = self
            .asSource()
            .observeOn(SignalSharingStrategy.scheduler)
            .catchError { error in
                return onErrorRecover(error).asSource().ignoreCompleted()
            }
            .ignoreCompleted(Never.self)
        return Signal(source)
    }
}
