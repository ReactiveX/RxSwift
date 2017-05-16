//
//  ControlPropertyTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxCocoa
import RxSwift
import RxTest

final class ControlPropertyTests : RxTest {
}

extension ControlPropertyTests {
    func testObservingIsAlwaysHappeningOnMainQueue() {
        let hotObservable = MainThreadPrimitiveHotObservable<Int>()

        var observedOnMainQueue = false

        let expectSubscribeOffMainQueue = expectation(description: "Did subscribe off main thread")

        let controlProperty = ControlProperty(values: Observable.deferred { () -> Observable<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            observedOnMainQueue = true
            return hotObservable.asObservable()
        }, valueSink: AnyObserver { n in
            
        })

        doOnBackgroundQueue {
            let d = controlProperty.asObservable().subscribe { n in

            }
            let d2 = controlProperty.subscribe { n in

            }
            doOnMainQueue {
                d.dispose()
                d2.dispose()
                expectSubscribeOffMainQueue.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }

        XCTAssertTrue(observedOnMainQueue)
    }
}

extension ControlPropertyTests {
    func testOrEmpty() {
        let bindingObserver = PrimitiveMockObserver<String?>()
        let controlProperty = ControlProperty<String?>(values: Observable.just(nil), valueSink: bindingObserver.asObserver())

        let orEmpty = controlProperty.orEmpty

        let finalObserver = PrimitiveMockObserver<String>()
        _ = orEmpty.subscribe(finalObserver)
        orEmpty.on(.next("a"))

        let bindingEvents: [Event<String>] = bindingObserver.events.map { $0.value.map { $0 ?? "" } }
        let observingEvents: [Event<String>] = finalObserver.events.map { $0.value.map { $0 } }
        XCTAssertArraysEqual(bindingEvents, [Event<String>.next("a")], ==)
        XCTAssertArraysEqual(observingEvents, [Event<String>.next(""), Event<String>.completed], ==)
    }

    func testChanged() {
        let behaviorSubject = BehaviorSubject(value: 0)

        let controlProperty = ControlProperty(values: behaviorSubject.asObserver(), valueSink: AnyObserver { _ in })

        let controlEvent = controlProperty.changed
        let changedObserver = PrimitiveMockObserver<Int>()
        let subscription = controlEvent.subscribe(changedObserver)

        XCTAssertEqual(changedObserver.events, [])

        behaviorSubject.on(.next(1))

        XCTAssertEqual(changedObserver.events, [next(1)])

        subscription.dispose()

        behaviorSubject.on(.next(2))

        XCTAssertEqual(changedObserver.events, [next(1)])
    }
}
