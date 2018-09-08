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

    if bag._pairs != nil {
        for i in bag._pairs!.indices {
            bag._pairs![i].value(event)
        }
    }
}

/// Dispatches `dispose` to all disposables contained inside bag.
func disposeAll(in bag: Bag<Disposable>) {
    if bag._value != nil {
        bag._value!.dispose()
    }

    if bag._pairs != nil {
        for i in bag._pairs!.indices {
            bag._pairs![i].value.dispose()
        }
    }
}
