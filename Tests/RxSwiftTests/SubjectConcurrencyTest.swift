//
//  SubjectConcurrencyTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

@testable import RxSwift
import XCTest
import Dispatch



final class ReplaySubjectConcurrencyTest : SubjectConcurrencyTest {
    override func createSubject() -> (Observable<Int>, AnyObserver<Int>) {
        let s = ReplaySubject<Int>.create(bufferSize: 1)
        return (s.asObservable(), AnyObserver(eventHandler: s.asObserver().on))
    }
}

final class BehaviorSubjectConcurrencyTest : SubjectConcurrencyTest {
    override func createSubject() -> (Observable<Int>, AnyObserver<Int>) {
        let s = BehaviorSubject<Int>(value: -1)
        return (s.asObservable(), AnyObserver(eventHandler: s.asObserver().on))
    }
}

class SubjectConcurrencyTest : RxTest {
    // default test is for publish subject
    func createSubject() -> (Observable<Int>, AnyObserver<Int>) {
        let s = PublishSubject<Int>()
        return (s.asObservable(), AnyObserver(eventHandler: s.asObserver().on))
    }
}

extension SubjectConcurrencyTest {
    func testSubjectIsReentrantForNextAndComplete() {
        let (observable, _observer) = createSubject()

        var state = 0

        let o = RxMutableBox(_observer)

        var ranAll = false

        _ = observable.subscribe(onNext: { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1

                // if isn't reentrant, this will cause deadlock
                o.value.on(.next(1))
            }
            else if state == 1 {
                // if isn't reentrant, this will cause deadlock
                o.value.on(.completed)
                ranAll = true
            }
        })

        o.value.on(.next(0))
        XCTAssertTrue(ranAll)
    }

    func testSubjectIsReentrantForNextAndError() {
        let (observable, _observer) = createSubject()

        var state = 0

        let o = RxMutableBox(_observer)

        var ranAll = false

        _ = observable.subscribe(onNext: { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1

                // if isn't reentrant, this will cause deadlock
                o.value.on(.next(1))
            }
            else if state == 1 {
                // if isn't reentrant, this will cause deadlock
                o.value.on(.error(testError))
                ranAll = true
            }
        })

        o.value.on(.next(0))
        XCTAssertTrue(ranAll)
    }
}
