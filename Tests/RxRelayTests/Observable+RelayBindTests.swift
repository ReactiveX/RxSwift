//
//  Observable+RelayBindTests.swift
//  Tests
//
//  Created by Shai Mishali on 09/04/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxRelay
import RxTest
import XCTest

class ObservableRelayBindTest: RxTest {
    
}

// MARK: bind(to:) publish relay
extension ObservableRelayBindTest {
    func testBindToPublishRelay() {
        var events: [Recorded<Event<Int>>] = []

        let relay = PublishRelay<Int>()

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1)
            ])
    }

    func testBindToPublishRelays() {
        var events1: [Recorded<Event<Int>>] = []
        var events2: [Recorded<Event<Int>>] = []

        let relay1 = PublishRelay<Int>()
        let relay2 = PublishRelay<Int>()

        _ = relay1.subscribe { event in
            events1.append(Recorded(time: 0, value: event))
        }

        _ = relay2.subscribe { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay1, relay2)

        XCTAssertEqual(events1, [
            .next(1)
            ])

        XCTAssertEqual(events2, [
            .next(1)
            ])
    }

    func testBindToOptionalPublishRelay() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = PublishRelay<Int?>()

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1)
            ])
    }

    func testBindToOptionalPublishRelays() {
        var events1: [Recorded<Event<Int?>>] = []
        var events2: [Recorded<Event<Int?>>] = []

        let relay1 = PublishRelay<Int?>()
        let relay2 = PublishRelay<Int?>()

        _ = relay1.subscribe { event in
            events1.append(Recorded(time: 0, value: event))
        }

        _ = relay2.subscribe { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay1, relay2)

        XCTAssertEqual(events1, [
            .next(1)
            ])

        XCTAssertEqual(events2, [
            .next(1)
            ])
    }

    func testBindToPublishRelayNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = PublishRelay<Int?>()

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1)
            ])
    }
}

// MARK: bind(to:) behavior relay
extension ObservableRelayBindTest {
    func testBindToBehaviorRelay() {
        let relay = BehaviorRelay<Int>(value: 0)

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }

    func testBindToBehaviorRelays() {
        let relay1 = BehaviorRelay<Int>(value: 0)
        let relay2 = BehaviorRelay<Int>(value: 0)

        _ = Observable.just(1).bind(to: relay1, relay2)

        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }

    func testBindToOptionalBehaviorRelay() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }

    func testBindToOptionalBehaviorRelays() {
        let relay1 = BehaviorRelay<Int?>(value: 0)
        let relay2 = BehaviorRelay<Int?>(value: 0)

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay1, relay2)

        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }

    func testBindToBehaviorRelayNoAmbiguity() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }
}

// MARK: bind(to:) replay relay
extension ObservableRelayBindTest {
    func testBindToReplayRelay() {
        var events: [Recorded<Event<Int>>] = []

        let relay = ReplayRelay<Int>.create(bufferSize: 1)

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1),
        ])
    }

    func testBindToReplayRelays() {
        var events1: [Recorded<Event<Int>>] = []
        var events2: [Recorded<Event<Int>>] = []

        let relay1 = ReplayRelay<Int>.create(bufferSize: 1)
        let relay2 = ReplayRelay<Int>.create(bufferSize: 1)

        _ = relay1.subscribe { event in
            events1.append(Recorded(time: 0, value: event))
        }

        _ = relay2.subscribe { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay1, relay2)

        XCTAssertEqual(events1, [
            .next(1),
        ])

        XCTAssertEqual(events2, [
            .next(1),
        ])
    }

    func testBindToOptionalReplayRelay() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = ReplayRelay<Int?>.create(bufferSize: 1)

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1),
        ])
    }

    func testBindToOptionalReplayRelays() {
        var events1: [Recorded<Event<Int?>>] = []
        var events2: [Recorded<Event<Int?>>] = []

        let relay1 = ReplayRelay<Int?>.create(bufferSize: 1)
        let relay2 = ReplayRelay<Int?>.create(bufferSize: 1)

        _ = relay1.subscribe { event in
            events1.append(Recorded(time: 0, value: event))
        }

        _ = relay2.subscribe { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay1, relay2)

        XCTAssertEqual(events1, [
            .next(1),
        ])

        XCTAssertEqual(events2, [
            .next(1),
        ])
    }

    func testBindToReplayRelayNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = ReplayRelay<Int?>.create(bufferSize: 1)

        _ = relay.subscribe { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1),
        ])
    }
}
