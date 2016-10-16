//
//  ControlPropertyTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxCocoa
import RxSwift
import RxTest

class ControlPropertyTests : RxTest {
}

extension ControlPropertyTests {
    func testObservingIsAlwaysHappeningOnMainThread() {
        let hotObservable = MainThreadPrimitiveHotObservable<Int>()

        var observedOnMainThread = false

        let expectSubscribeOffMainThread = expectation(description: "Did subscribe off main thread")

        let controlProperty = ControlProperty(values: Observable.deferred { () -> Observable<Int> in
            XCTAssertTrue(isMainThread())
            observedOnMainThread = true
            return hotObservable.asObservable()
        }, valueSink: AnyObserver { n in
            
        })

        doOnBackgroundThread {
            let d = controlProperty.asObservable().subscribe { n in

            }
            let d2 = controlProperty.subscribe { n in

            }
            doOnMainThread {
                d.dispose()
                d2.dispose()
                expectSubscribeOffMainThread.fulfill()
            }
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }

        XCTAssertTrue(observedOnMainThread)
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
}
