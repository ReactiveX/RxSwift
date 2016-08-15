//
//  SubjectConcurrencyTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 11/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest


class ReplaySubjectConcurrencyTest : SubjectConcurrencyTest {
    override func createSubject() -> (Observable<Int>, AnyObserver<Int>) {
        let s = ReplaySubject<Int>.create(bufferSize: 1)
        return (s.asObservable(), AnyObserver(eventHandler: s.asObserver().on))
    }
}

class BehaviorSubjectConcurrencyTest : SubjectConcurrencyTest {
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
    func testSubjectIsSynchronized() {
        let (observable, _observer) = createSubject()

        let o = RxMutableBox(_observer)

        var allDone = false

        var state = 0
        _ = observable.subscribe(onNext: { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1
                DispatchQueue.global(qos: DispatchQoS.QoSClass.userInitiated).async {
                    o.value.on(.next(1))
                }

                // if other thread can't fulfill the condition in 0.5 sek, that means it is synchronized
                Thread.sleep(forTimeInterval: 0.5)

                XCTAssertEqual(state, 1)

                DispatchQueue.main.async {
                    o.value.on(.next(2))
                }
            }
            else if state == 1 {
                XCTAssertTrue(!isMainThread())
                state = 2
            }
            else if state == 2 {
                XCTAssertTrue(isMainThread())
                allDone = true
            }
        })

        _observer.on(.next(0))

        // wait for second
        for _ in 0 ..< 10 {
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
            if allDone {
                break
            }
        }

        XCTAssertTrue(allDone)
    }

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
