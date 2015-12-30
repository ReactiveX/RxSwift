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
        _ = observable.subscribeNext { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
                    o.value.on(.Next(1))
                }

                // if other thread can't fulfill the condition in 0.5 sek, that means it is synchronized
                NSThread.sleepForTimeInterval(0.5)

                XCTAssertEqual(state, 1)

                dispatch_async(dispatch_get_main_queue()) {
                    o.value.on(.Next(2))
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
        }

        _observer.on(.Next(0))

        // wait for second
        for _ in 0 ..< 10 {
            NSRunLoop.currentRunLoop().runUntilDate(NSDate().dateByAddingTimeInterval(0.1))
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

        _ = observable.subscribeNext { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1

                // if isn't reentrant, this will cause deadlock
                o.value.on(.Next(1))
            }
            else if state == 1 {
                // if isn't reentrant, this will cause deadlock
                o.value.on(.Completed)
                ranAll = true
            }
        }

        o.value.on(.Next(0))
        XCTAssertTrue(ranAll)
    }

    func testSubjectIsReentrantForNextAndError() {
        let (observable, _observer) = createSubject()

        var state = 0

        let o = RxMutableBox(_observer)

        var ranAll = false

        _ = observable.subscribeNext { [unowned o] n in
            if n < 0 {
                return
            }

            if state == 0 {
                state = 1

                // if isn't reentrant, this will cause deadlock
                o.value.on(.Next(1))
            }
            else if state == 1 {
                // if isn't reentrant, this will cause deadlock
                o.value.on(.Error(testError))
                ranAll = true
            }
        }

        o.value.on(.Next(0))
        XCTAssertTrue(ranAll)
    }
}
