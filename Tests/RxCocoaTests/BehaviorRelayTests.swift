//
//  BehaviorRelayTests.swift
//  Tests
//
//  Created by Jon Bott on 5/1/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest

class BehaviorRelayTests : XCTestCase {

    var behaviorRelay: BehaviorRelay<String>!
    var bag: DisposeBag!
    let initialValue = "initialValue"
    let nextValue = "nextValue"
    let finalValue = "final value"

    override func setUp() {
        behaviorRelay = BehaviorRelay(value: initialValue)
        bag = DisposeBag()
    }

    func testSetValue_getInitialValue() {
        XCTAssertEqual(behaviorRelay.value, initialValue)
    }

    func testSetValue_valueIsChanged() {
        behaviorRelay.value = nextValue
        XCTAssertEqual(behaviorRelay.value, nextValue)
    }

    func testSetValue_newValueReflectsInSubscription() {
        var latestValue: String?

        behaviorRelay.asObservable().subscribe(onNext: { next in
            latestValue = next
        }).disposed(by: bag)

        behaviorRelay.value = finalValue

        XCTAssertEqual(latestValue!, finalValue)
    }
}
