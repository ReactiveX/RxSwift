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

// MARK: bindTo observer

extension ObservableBindTest {
    func testBindToObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bindTo(observer)

        XCTAssertEqual(events, [
            next(1),
            completed()
            ])
    }

    func testBindToOptionalObserver() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Observable.just(1) as Observable<Int>).bindTo(observer)

        XCTAssertEqual(events[0].value.element!, 1)
        guard case .completed = events[1].value else {
            XCTFail("Not completed")
            return
        }
    }

    func testBindToOptionalObserverNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Observable.just(1).bindTo(observer)

        XCTAssertEqual(events[0].value.element!, 1)
        guard case .completed = events[1].value else {
            XCTFail("Not completed")
            return
        }
    }
}

// MARK: bindTo variable

extension ObservableBindTest {
    func testBindToVariable() {
        let variable = Variable<Int>(0)

        _ = Observable.just(1).bindTo(variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testBindToOptionalVariable() {
        let variable = Variable<Int?>(0)

        _ = (Observable.just(1) as Observable<Int>).bindTo(variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testBindToVariableNoAmbiguity() {
        let variable = Variable<Int?>(0)

        _ = Observable.just(1).bindTo(variable)

        XCTAssertEqual(variable.value, 1)
    }
}
