//
//  Infallible+BindTests.swift
//  Tests
//
//  Created by Shai Mishali on 11/20/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTest
import XCTest

final class InfallibleBindTest: RxTest {

}

// MARK: bind(to:) observer

extension InfallibleBindTest {
    func testBindToObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Infallible.just(1).bind(to: observer)

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

        _ = Infallible.just(1).bind(to: observer1, observer2)

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

        _ = (Infallible.just(1) as Infallible<Int>).bind(to: observer)

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

        _ = (Infallible.just(1) as Infallible<Int>).bind(to: observer1, observer2)

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

        _ = Infallible.just(1).bind(to: observer)

        XCTAssertEqual(events[0].value.element!, 1)
        guard case .completed = events[1].value else {
            XCTFail("Not completed")
            return
        }
    }
}

// MARK: bind(to:) curried

extension InfallibleBindTest {
    func testBindToCurried1() {
        var result: Int? = nil
        let binder: (Infallible<Int>) -> Disposable =  { obs in
            return obs.subscribe(onNext: { element in
                result = element
            })
        }

        XCTAssertNil(result)

        let d: Disposable = Infallible.just(1).bind(to: binder)

        XCTAssertEqual(result, 1)
        d.dispose()
    }

    func testBindToCurried2() {
        var result: Int? = nil
        let binder: (Infallible<Int>) -> (Int) -> Disposable =  { obs in
            return { other in
                return obs.subscribe(onNext: { element in
                    result = element + other
                })
            }
        }

        XCTAssertNil(result)

        let d: Disposable = Infallible.just(1).bind(to: binder)(3)

        XCTAssertEqual(result, 4)
        d.dispose()
    }
}
