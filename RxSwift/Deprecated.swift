//
//  Deprecated.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/5/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension Observable {
    /**
     Converts a optional to an observable sequence.
     
     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)
     
     - parameter optional: Optional element in the resulting observable sequence.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    @available(*, deprecated, message: "Implicit conversions from any type to optional type are allowed and that is causing issues with `from` operator overloading.", renamed: "from(optional:)")
    public static func from(_ optional: E?) -> Observable<E> {
        return Observable.from(optional: optional)
    }

    /**
     Converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.
     - parameter: Scheduler to send the optional element on.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    @available(*, deprecated, message: "Implicit conversions from any type to optional type are allowed and that is causing issues with `from` operator overloading.", renamed: "from(optional:scheduler:)")
    public static func from(_ optional: E?, scheduler: ImmediateSchedulerType) -> Observable<E> {
        return Observable.from(optional: optional, scheduler: scheduler)
    }
}

extension ObservableType {
    /**

    ** @available(*, deprecated, message: "Please use enumerated().map()", renamed: "enumerated().map()") **

     Projects each element of an observable sequence into a new form by incorporating the element's index.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter selector: A transform function to apply to each source element; the second parameter of the function represents the index of the source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.
     */
    public func mapWithIndex<R>(_ selector: @escaping (E, Int) throws -> R)
        -> Observable<R> {
        return enumerated().map { try selector($0.element, $0.index) }
    }


    /**

     ** @available(*, deprecated, message: "Please use enumerated().flatMap()", renamed: "enumerated().flatMap()") **

     Projects each element of an observable sequence to an observable sequence by incorporating the element's index and merges the resulting observable sequences into one observable sequence.

     - seealso: [flatMap operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element; the second parameter of the function represents the index of the source element.
     - returns: An observable sequence whose elements are the result of invoking the one-to-many transform function on each element of the input sequence.
     */
    public func flatMapWithIndex<O: ObservableConvertibleType>(_ selector: @escaping (E, Int) throws -> O)
        -> Observable<O.E> {
        return enumerated().flatMap { try selector($0.element, $0.index) }
    }

    /**

     ** @available(*, deprecated, message: "Please use enumerated().skipWhile().map()", renamed: "enumerated().skipWhile().map()") **
     
     Bypasses elements in an observable sequence as long as a specified condition is true and then returns the remaining elements.
     The element's index is used in the logic of the predicate function.

     - seealso: [skipWhile operator on reactivex.io](http://reactivex.io/documentation/operators/skipwhile.html)

     - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
     - returns: An observable sequence that contains the elements from the input sequence starting at the first element in the linear series that does not pass the test specified by predicate.
     */
    public func skipWhileWithIndex(_ predicate: @escaping (E, Int) throws -> Bool) -> Observable<E> {
        return enumerated().skipWhile { try predicate($0.element, $0.index) }.map { $0.element }
    }


    /**
     
     ** @available(*, deprecated, message: "Please use enumerated().takeWhile().map()", renamed: "enumerated().takeWhile().map()") **
     
     Returns elements from an observable sequence as long as a specified condition is true.

     The element's index is used in the logic of the predicate function.

     - seealso: [takeWhile operator on reactivex.io](http://reactivex.io/documentation/operators/takewhile.html)

     - parameter predicate: A function to test each element for a condition; the second parameter of the function represents the index of the source element.
     - returns: An observable sequence that contains the elements from the input sequence that occur before the element at which the test no longer passes.
     */
    public func takeWhileWithIndex(_ predicate: @escaping (E, Int) throws -> Bool) -> Observable<E> {
        return enumerated().takeWhile { try predicate($0.element, $0.index) }.map { $0.element }
    }
}

extension Disposable {
    /// Deprecated in favor of `disposed(by:)`
    ///
    /// **@available(\*, deprecated, message="use disposed(by:) instead")**
    ///
    /// Adds `self` to `bag`.
    ///
    /// - parameter bag: `DisposeBag` to add `self` to.
    public func addDisposableTo(_ bag: DisposeBag) {
        disposed(by: bag)
    }
}
