//
//  BehaviorRelay+PropertyWrapper.swift
//  Rx
//
//  Created by Vova Bondar on 27.05.2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxRelay
import RxTest
import XCTest

class BehaviorRelayPropertyWrapperTest: RxTest {

}

extension BehaviorRelayPropertyWrapperTest {
    private class RelayWrapper {
        @BehaviorRelay var counter: Int = 0
    }

    func testBehaviorRelay_baseValue() {
        var events: [Recorded<Event<Int>>] = []

        let relay = RelayWrapper()

        _ = relay.$counter.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        XCTAssertEqual(events, [
            .next(0)
        ])
    }

    func testBehaviorRelay_sendWithWrappedValue() {
        var events: [Recorded<Event<Int>>] = []

        let relay = RelayWrapper()

        _ = relay.$counter.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        relay.counter = 1

        XCTAssertEqual(events, [
            .next(0),
            .next(1)
        ])
    }

    func testBehaviorRelay_sendWithProjectedValueValue() {
        var events: [Recorded<Event<Int>>] = []

        let relay = RelayWrapper()

        _ = relay.$counter.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        relay.$counter.accept(1)

        XCTAssertEqual(events, [
            .next(0),
            .next(1)
        ])
    }
}
