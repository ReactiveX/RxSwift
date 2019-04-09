//
//  Observable+BindTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/11/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class ObservableBindTest: RxTest {

}

// MARK: bind(to:) observer

extension ObservableBindTest {
    func testBindToObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: observer)

        XCTAssertEqual(events, [
            .next(1),
            .completed()
        ])
    }

    func testBindToObservers() {
        var events1: [Recorded<Event<Int>>] = []
        var events2: [Recorded<Event<Int>>] = []

        let observer1: AnyObserver<Int> = AnyObserver { event in
            events1.append(Recorded(time: 0, value: event))
        }

        let observer2: AnyObserver<Int> = AnyObserver { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: observer1, observer2)

        XCTAssertEqual(events1, [
            .next(1),
            .completed()
        ])

        XCTAssertEqual(events2, [
            .next(1),
            .completed()
        ])
    }

    func testBindToOptionalObserver() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: observer)

        XCTAssertEqual(events[0].value.element!, 1)
        guard case .completed = events[1].value else {
            XCTFail("Not completed")
            return
        }
    }

    func testBindToOptionalObservers() {
        var events1: [Recorded<Event<Int?>>] = []
        var events2: [Recorded<Event<Int?>>] = []

        let observer1: AnyObserver<Int?> = AnyObserver { event in
            events1.append(Recorded(time: 0, value: event))
        }

        let observer2: AnyObserver<Int?> = AnyObserver { event in
            events2.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bind(to: observer1, observer2)

        XCTAssertEqual(events1, [
            .next(1),
            .completed()
        ])

        XCTAssertEqual(events2, [
            .next(1),
            .completed()
        ])
    }

    func testBindToOptionalObserverNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bind(to: observer)

        XCTAssertEqual(events[0].value.element!, 1)
        guard case .completed = events[1].value else {
            XCTFail("Not completed")
            return
        }
    }
}

// MARK: bind(to:) variable

extension ObservableBindTest {
    func testBindToVariable() {
        let variable = Variable<Int>(0)

        _ = Observable.just(1).bind(to: variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testBindToOptionalVariable() {
        let variable = Variable<Int?>(0)

        _ = (Observable.just(1) as Observable<Int>).bind(to: variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testBindToVariableNoAmbiguity() {
        let variable = Variable<Int?>(0)

        _ = Observable.just(1).bind(to: variable)

        XCTAssertEqual(variable.value, 1)
    }
}

// MARK: bind(to:) publish relay

extension ObservableBindTest {
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

        _ = Observable.just(1).bind(to: relay1, relay2)

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

extension ObservableBindTest {
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

        _ = Observable.just(1).bind(to: relay1, relay2)

        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }

    func testBindToBehaviorRelayNoAmbiguity() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = Observable.just(1).bind(to: relay)

        XCTAssertEqual(relay.value, 1)
    }
}

// MARK: bind(to:) curried

extension ObservableBindTest {
    func testBindToCurried1() {
        var result: Int? = nil
        let binder: (Observable<Int>) -> Disposable =  { obs in
            return obs.subscribe(onNext: { element in
                result = element
            })
        }

        XCTAssertNil(result)

        let d: Disposable = Observable.just(1).bind(to: binder)

        XCTAssertEqual(result, 1)
        d.dispose()
    }

    func testBindToCurried2() {
        var result: Int? = nil
        let binder: (Observable<Int>) -> (Int) -> Disposable =  { obs in
            return { other in
                return obs.subscribe(onNext: { element in
                    result = element + other
                })
            }
        }

        XCTAssertNil(result)

        let d: Disposable = Observable.just(1).bind(to: binder)(3)

        XCTAssertEqual(result, 4)
        d.dispose()
    }

}
