//
//  ReplayRelayTests.swift
//  Tests
//
//  Created by Zsolt Kovacs on 12/31/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxRelay
import RxTest

class ReplayRelayTests: RxTest {
    func test_noEvents() {
        let scheduler = TestScheduler(initialClock: 0)

        let relay = ReplayRelay<Int>.create(bufferSize: 3)
        let result = scheduler.createObserver(Int.self)

        _ = relay.subscribe(result)

        XCTAssertTrue(result.events.isEmpty)
    }

    func test_fewerEventsThanBufferSize() {
        let scheduler = TestScheduler(initialClock: 0)

        var relay: ReplayRelay<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { relay = ReplayRelay.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { relay.accept(1) }
        scheduler.scheduleAt(200) { relay.accept(2) }
        scheduler.scheduleAt(300) { subscription = relay.subscribe(result) }
        scheduler.scheduleAt(350) {
            XCTAssertEqual(result.events, [
                .next(300, 1),
                .next(300, 2),
            ])
        }
        scheduler.scheduleAt(400) { subscription.dispose() }

        scheduler.start()
    }

    func test_moreEventsThanBufferSize() {
        let scheduler = TestScheduler(initialClock: 0)

        var relay: ReplayRelay<Int>! = nil
        let result = scheduler.createObserver(Int.self)
        var subscription: Disposable! = nil

        scheduler.scheduleAt(100) { relay = ReplayRelay.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { relay.accept(1) }
        scheduler.scheduleAt(200) { relay.accept(2) }
        scheduler.scheduleAt(250) { relay.accept(3) }
        scheduler.scheduleAt(300) { relay.accept(4) }
        scheduler.scheduleAt(350) { relay.accept(5) }
        scheduler.scheduleAt(400) { subscription = relay.subscribe(result) }
        scheduler.scheduleAt(450) {
            XCTAssertEqual(result.events, [
                .next(400, 3),
                .next(400, 4),
                .next(400, 5),
            ])
        }
        scheduler.scheduleAt(500) { subscription.dispose() }

        scheduler.start()
    }

    func test_moreEventsThanBufferSizeMultipleObservers() {
        let scheduler = TestScheduler(initialClock: 0)

        var relay: ReplayRelay<Int>! = nil
        let result1 = scheduler.createObserver(Int.self)
        var subscription1: Disposable! = nil

        let result2 = scheduler.createObserver(Int.self)
        var subscription2: Disposable! = nil

        scheduler.scheduleAt(100) { relay = ReplayRelay.create(bufferSize: 3) }
        scheduler.scheduleAt(150) { subscription1 = relay.subscribe(result1) }
        scheduler.scheduleAt(200) { relay.accept(1) }
        scheduler.scheduleAt(250) { relay.accept(2) }
        scheduler.scheduleAt(300) { relay.accept(3) }
        scheduler.scheduleAt(350) { relay.accept(4) }
        scheduler.scheduleAt(400) { relay.accept(5) }
        scheduler.scheduleAt(450) { subscription2 = relay.subscribe(result2) }
        scheduler.scheduleAt(500) {
            XCTAssertEqual(result1.events, [
                .next(200, 1),
                .next(250, 2),
                .next(300, 3),
                .next(350, 4),
                .next(400, 5),
            ])
            XCTAssertEqual(result2.events, [
                .next(450, 3),
                .next(450, 4),
                .next(450, 5),
            ])
        }
        scheduler.scheduleAt(550) {
            subscription1.dispose()
            subscription2.dispose()
        }

        scheduler.start()
    }
}
