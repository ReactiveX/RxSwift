//
//  Never.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    static func never() -> Observable<Element> {
        NeverProducer()
    }
}

private final class NeverProducer<Element>: Producer<Element> {
    override func subscribe<Observer: ObserverType>(_: Observer) -> Disposable where Observer.Element == Element {
        Disposables.create()
    }
}
