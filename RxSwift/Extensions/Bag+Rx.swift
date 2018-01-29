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
    bag.forEach { eventHandler in
        eventHandler(event)
    }
}

/// Dispatches `dispose` to all disposables contained inside bag.
func disposeAll(in bag: Bag<Disposable>) {
    bag.forEach {
        $0.dispose()
    }
}
