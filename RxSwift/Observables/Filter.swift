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
    public func filter(_ predicate: @escaping (Element) -> Bool)
        -> ObservableSource<Element, Completed, Error> {
        let source = self.source
        return ObservableSource(run: .run { observer, cancel in
            return source.run({ event in
                switch event {
                case .next(let element):
                    if predicate(element) {
                        observer(.next(element))
                    }
                case .error, .completed:
                    observer(event)
                }
            }, cancel)
        })
    }
}

extension ObservableType where Error == Swift.Error {
    /**
     Filters the elements of an observable sequence based on a predicate.
     
     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
     
     - parameter predicate: A function to test each source element for a condition.
     - returns: An observable sequence that contains elements from the input sequence that satisfy the condition.
     */
    public func filter(_ predicate: @escaping (Element) throws -> Bool)
        -> ObservableSource<Element, Completed, Error> {
        let source = self.source
        return ObservableSource(run: .run { observer, cancel in
            return source.run({ event in
                switch event {
                case .next(let element):
                    do {
                        if try predicate(element) {
                            observer(.next(element))
                        }
                    } catch let error {
                        observer(.error(error))
                    }
                case .error, .completed:
                    observer(event)
                }
            }, cancel)
        })
    }
}

//extension ObservableType {
//
//    /**
//     Skips elements and completes (or errors) when the observable sequence completes (or errors). Equivalent to filter that always returns false.
//
//     - seealso: [ignoreElements operator on reactivex.io](http://reactivex.io/documentation/operators/ignoreelements.html)
//
//     - returns: An observable sequence that skips all elements of the source sequence.
//     */
//    public func ignoreElements()
//        -> Completable {
//        return ObservableSource { observer, cancel in
//            return source.run({ event in
//                switch event {
//                case .next:
//                case .completed(let completed):
//                    observer(.completed(completed))
//                case .error(let error):
//                    observer(.error(error))
//                }
//            }, cancel)
//        }
//    }
//}
