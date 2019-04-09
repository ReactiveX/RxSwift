//
//  Observable+RelayBindTests.swift
//  RxSwift
//
//  Created by Shai Mishali on 09/04/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxRelay
import RxTest
import XCTest

final class ObservableRelayBindTest: RxTest {
    
}

// MARK: bind(to:) publish relay
extension ObservableRelayBindTest {
    func testBindToPublishRelay() {
        var events: [Recorded<Event<Int>>] = []

        let relay = PublishRelay<Int>()

        _ = relay.subscribe{ event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1)
            ])
    }

    func testBindToOptionalPublishRelay() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = PublishRelay<Int?>()

        _ = relay.subscribe{ event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay)

        XCTAssertEqual(events, [
            .next(1)
            ])
    }

    func testBindToPublishRelayNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let relay = PublishRelay<Int?>()

        _ = relay.subscribe{ event in
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

    func testBindToOptionalBehaviorRelay() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = (Observable.just(1) as Observable<Int>).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }

    func testBindToBehaviorRelayNoAmbiguity() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }
}
