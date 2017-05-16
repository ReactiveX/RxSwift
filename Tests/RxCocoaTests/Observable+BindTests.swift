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
            next(1),
            completed()
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
