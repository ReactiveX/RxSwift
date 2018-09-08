//
//  Bag+Rx.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 10/19/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//


// MARK: forEach

@inline(__always)
func dispatch<E>(_ bag: Bag<(Event<E>) -> ()>, _ event: Event<E>) {
    if bag._value != nil {
        bag._value!(event)
    }

    let _pairs = bag._pairs
    if _pairs != nil {
        for i in _pairs!.indices {
            _pairs![i].value(event)
        }
    }
}

/// Dispatches `dispose` to all disposables contained inside bag.
func disposeAll(in bag: Bag<Disposable>) {
    if bag._value != nil {
        bag._value!.dispose()
    }

    let _pairs = bag._pairs
    if _pairs != nil {
        for i in _pairs!.indices {
            _pairs![i].value.dispose()
        }
    }
}
