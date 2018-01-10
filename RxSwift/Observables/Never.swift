//
//  Never.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Returns a non-terminating observable sequence, which can be used to denote an infinite duration.

     - seealso: [never operator on reactivex.io](http://reactivex.io/documentation/operators/empty-never-throw.html)

     - returns: An observable sequence whose observers will never get called.
     */
    public static func never() -> Observable<E> {
        return NeverProducer()
    }
}

final fileprivate class NeverProducer<Element> : Producer<Element> {
    override func subscribe(_ observer: @escaping (Event<Element>) -> ()) -> Disposable {
        return Disposable.create()
    }
}
