//
//  SharedSequence+Test.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/27/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import RxSwift
import RxCocoa
import XCTest
import RxTest

class SharedSequenceTest : RxTest {
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

    override func tearDown() {
        super.tearDown()
    }
}

// test helpers that make sure that resulting driver operator honors definition
// * only one subscription is made and shared - shareReplay(1)
// * subscription is made on main thread - subscribeOn(ConcurrentMainScheduler.instance)
// * events are observed on main thread - observeOn(MainScheduler.instance)
// * it can't error out - it needs to have catch somewhere
extension SharedSequenceTest {

    func subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription<R, S>(_ xs: SharedSequence<S, R>, expectationFulfilled: @escaping (R) -> Bool = { _ in false }, subscribedOnBackground: () -> Void) -> [R] {
        var firstElements = [R]()
        var secondElements = [R]()

        let subscribeFinished = self.expectation(description: "subscribeFinished")

        var expectation1: XCTestExpectation!
        var expectation2: XCTestExpectation!

        _ = backgroundScheduler.schedule(()) { _ in
            var subscribing1 = true
            let firstSubscriptionFuture = SingleAssignmentDisposable()
            let firstSubscription = xs.asObservable().subscribe { e in
                if !subscribing1 {
                    XCTAssertTrue(DispatchQueue.isMain)
                }
                switch e {
                case .next(let element):
                    firstElements.append(element)
                    if expectationFulfilled(element) {
                        expectation1.fulfill()
                        firstSubscriptionFuture.dispose()
                    }
                case .error(let error):
                    XCTFail("Error passed \(error)")
                case .completed:
                    expectation1.fulfill()
                }
            }
            firstSubscriptionFuture.setDisposable(firstSubscription)
            subscribing1 = false

            var subscribing = true
            let secondSubscriptionFuture = SingleAssignmentDisposable()
            let secondSubscription = xs.asObservable().subscribe { e in
                if !subscribing {
                    XCTAssertTrue(DispatchQueue.isMain)
                }
                switch e {
                case .next(let element):
                    secondElements.append(element)
                    if expectationFulfilled(element) {
                        expectation2.fulfill()
                        secondSubscriptionFuture.dispose()
                    }
                case .error(let error):
                    XCTFail("Error passed \(error)")
                case .completed:
                    expectation2.fulfill()
                }
            }
            secondSubscriptionFuture.setDisposable(secondSubscription)

            subscribing = false

            // Subscription should be made on main scheduler
            // so this will make sure execution is continued after
            // subscription because of serial nature of main scheduler.
            _ = MainScheduler.instance.schedule(()) { _ in
                subscribeFinished.fulfill()
                return Disposables.create()
            }

            return Disposables.create()
        }

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertTrue(error == nil)
        }

        expectation1 = self.expectation(description: "finished1")
        expectation2 = self.expectation(description: "finished2")

        subscribedOnBackground()

        waitForExpectations(timeout: 1.0) { error in
            XCTAssertTrue(error == nil)
        }
        
        return firstElements
    }
}
