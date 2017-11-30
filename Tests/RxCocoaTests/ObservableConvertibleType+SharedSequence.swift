//
//  ObservableConvertibleType+SharedSequence.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest
import RxTest

class ObservableConvertibleSharedSequenceTests : SharedSequenceTest { }

extension ObservableConvertibleSharedSequenceTests {
    func testAsSharedSequence_onErrorJustReturn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let sharedSequence: Signal<Int> = hotObservable.asSharedSequence(onErrorJustReturn: -1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(sharedSequence) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsSharedSequence_onErrorDriveWith() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let sharedSequence: Signal<Int> = hotObservable.asSharedSequence(onErrorDriveWith: .just(-2))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(sharedSequence) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -2])
    }

    func testAsSharedSequence_onErrorRecover() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let sharedSequence: Signal<Int> = hotObservable.asSharedSequence(onErrorRecover: { (error) -> Signal<Int> in
            return .just(-3)
        })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(sharedSequence) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -3])
    }
}
