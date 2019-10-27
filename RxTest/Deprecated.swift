//
//  Deprecated.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension TestScheduler {
    @available(*, deprecated, renamed: "start(disposed:create:)")
    public func start<Element>(_ disposed: TestTime, create: @escaping () -> Observable<Element>) -> TestableObserver<Element> {
        self.start(Defaults.created, subscribed: Defaults.subscribed, disposed: disposed, create: create)
    }

    @available(*, deprecated, renamed: "start(created:subscribed:disposed:create:)")
    public func start<Element>(_ created: TestTime, subscribed: TestTime, disposed: TestTime, create: @escaping () -> Observable<Element>) -> TestableObserver<Element> {
        self.start(created: created, subscribed: subscribed, disposed: disposed, create: create)
    }
}

/**
 These methods are conceptually extensions of `XCTestCase` but because referencing them in closures would
 require specifying `self.*`, they are made global.
 */
//extension XCTestCase {
    /**
     Factory method for an `.next` event recorded at a given time with a given value.
 
     - parameter time: Recorded virtual time the `.next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
     */
    @available(*, deprecated, renamed: "Recorded.next(_:_:)")
    public func next<T>(_ time: TestTime, _ element: T) -> Recorded<Event<T>> {
        Recorded.next(time, element)
    }

    /**
     Factory method for an `.completed` event recorded at a given time.
 
     - parameter time: Recorded virtual time the `.completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
     */
    @available(*, deprecated, renamed: "Recorded.completed(_:_:)")
    public func completed<T>(_ time: TestTime, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        Recorded.completed(time, type)
    }

    /**
     Factory method for an `.error` event recorded at a given time with a given error.
 
     - parameter time: Recorded virtual time the `.completed` event occurs.
     */
    @available(*, deprecated, renamed: "Recorded.error(_:_:_:)")
    public func error<T>(_ time: TestTime, _ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> {
        Recorded.error(time, error, type)
    }
//}
