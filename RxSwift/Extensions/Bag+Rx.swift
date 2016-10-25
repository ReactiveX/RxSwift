//
//  Bag+Rx.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/19/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation


// MARK: forEach

extension Bag where T: ObserverType {
    /// Dispatches `event` to app observers contained inside bag.
    ///
    /// - parameter action: Enumeration closure.
    func on(_ event: Event<T.E>) {
        if _onlyFastPath {
            _value0?.on(event)
            return
        }

        let pairs = _pairs
        let value0 = _value0
        let value1 = _value1
        let dictionary = _dictionary

        value0?.on(event)

        value1?.on(event)

        for i in 0 ..< pairs.count {
            pairs[i].value.on(event)
        }

        dictionary?.values.forEach { $0.on(event) }

    }
}

/// Dispatches `dispose` to all disposables contained inside bag.
func disposeAll(in bag: Bag<Disposable>) {
    if bag._onlyFastPath {
        bag._value0?.dispose()
        return
    }

    let pairs = bag._pairs
    let value0 = bag._value0
    let value1 = bag._value1
    let dictionary = bag._dictionary

    value0?.dispose()

    value1?.dispose()

    for i in 0 ..< pairs.count {
        pairs[i].value.dispose()
    }

    dictionary?.values.forEach { $0.dispose() }

}
