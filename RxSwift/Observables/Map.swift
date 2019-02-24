//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Projects each element of an observable sequence into a new form.
     
     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)
     
     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     
     */
    public func map<Result>(_ transform: @escaping (Element, Completed, Error) -> Result)
        -> ObservableSource<Result, Completed, Error> {
        let source = self.asSource()
        return ObservableSource { nextObserver, cancel in
            let observer: ObservableSource<Element, Completed, Error>.Observer = { event in
                nextObserver(event.map(transform))
            }
            return source.run(observer, cancel)
        }
    }
}

extension ObservableType where Error == Swift.Error {
    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<Result>(_ transform: @escaping (Element, Completed, Error) throws -> Result)
        -> ObservableSource<Result, Completed, Error> {
        let source = self.asSource()
        return ObservableSource { nextObserver, cancel in
            let observer: ObservableSource<Element, Completed, Error>.Observer = { event in
                nextObserver(event.map(transform))
            }
            return source.run(observer, cancel)
        }
    }
}
