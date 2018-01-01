//
//  Filter.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Filters the elements of an observable sequence based on a predicate.

     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)

     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (E) throws -> Bool)
        -> Observable<E> {
        return Filter(source: asObservable(), predicate: predicate)
    }
}

//extension ObservableType {
//
//    /**
//     Skips elements and completes (or errors) when the receiver completes (or errors). Equivalent to filter that always returns false.
//
//     - seealso: [ignoreElements operator on reactivex.io](http://reactivex.io/documentation/operators/ignoreelements.html)
//
//     - returns: An observable sequence that skips all elements of the source sequence.
//     */
//    public func ignoreElements()
//        -> Completable {
//            return flatMap { _ in
//                return Observable<Never>.empty()
//            }
//            .asCompletable()
//    }
//}

final fileprivate class Filter<Element> : Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    private let _source: Observable<Element>
    private let _predicate: Predicate
    
    init(source: Observable<Element>, predicate: @escaping Predicate) {
        _source = source
        _predicate = predicate
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = _source.subscribe { event in
            switch event {
            case .next(let value):
                do {
                    let satisfies = try self._predicate(value)
                    if satisfies {
                        sink.forwardOn(.next(value))
                    }
                }
                catch let e {
                    sink.forwardOn(.error(e))
                    sink.dispose()
                }
            case .completed, .error:
                sink.forwardOn(event)
                sink.dispose()
            }
        }
        return (sink: sink, subscription: subscription)
    }
}
