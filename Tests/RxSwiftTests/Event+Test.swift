//
//  Event+Test.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/16/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
import RxTest

class EventTests: RxTest {

}

extension EventTests {
    func testMapTransformNext() {
        let original = Event.next(1)

        XCTAssertEqual(Event.next(2), original.map { x -> Int in x + 1 }) { $0 == $1 }
    }

    func testMapTransformNextThrow() {
        let original = Event.next(1)

        XCTAssertEqual(Event.error(testError), original.map { _ -> Int in throw testError }) { $0 == $1 }
    }

    func testMapTransformError() {
        let original = Event<Int>.error(testError2)

        XCTAssertEqual(Event.error(testError2), original.map { _ -> Int in throw testError }) { $0 == $1 }
    }

    func testMapTransformCompleted() {
        let original = Event<Int>.completed

        XCTAssertEqual(Event.completed, original.map { _ -> Int in throw testError }) { $0 == $1 }
    }
}

