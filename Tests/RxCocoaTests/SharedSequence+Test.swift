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

class SharedSequenceTest: RxTest {
    var backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)

    override func tearDown() {
        super.tearDown()
    }
}

// test helpers that make sure that resulting driver operator honors definition
// * only one subscription is made and shared - shareReplay(1)
// * subscription is made on main thread - subscribe(on: ConcurrentMainScheduler.instance)
// * events are observed on main thread - observe(on:MainScheduler.instance)
// * it can't error out - it needs to have catch somewhere
extension SharedSequenceTest {
    func subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription<Result, S>(_ xs: SharedSequence<S, Result>, expectationFulfilled: @escaping (Result) -> Bool = { _ in false }, subscribedOnBackground: () -> Void) -> [Result] {
        var firstElements = [Result]()
        var secondElements = [Result]()

        let subscribeFinished = self.expectation(description: "subscribeFinished")

        var expectation1: XCTestExpectation!
        var expectation2: XCTestExpectation!

        _ = backgroundScheduler.schedule(()) { _ in
            let subscribing1 = AtomicInt(1)
            let firstSubscriptionFuture = SingleAssignmentDisposable()
            let firstSubscription = xs.asObservable().subscribe { e in
                if globalLoad(subscribing1) == 0 {
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
            sub(subscribing1, 1)

            let subscribing = AtomicInt(1)
            let secondSubscriptionFuture = SingleAssignmentDisposable()
            let secondSubscription = xs.asObservable().subscribe { e in
                if globalLoad(subscribing) == 0 {
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

            sub(subscribing, 1)

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

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testDriverWorksOnMainActor() async {
        for await value in await Observable.just(1)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .asDriver(onErrorDriveWith: .empty())
            .map({ @MainActor one in
                MainActor.shared.assertIsolated()
                return one + 1
            })
            .values {
            XCTAssertEqual(value, 2)
        }
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testSignalWorksOnMainActor() async {
        for await value in await Observable.just(1)
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .asSignal(onErrorSignalWith: .empty())
            .map({ @MainActor one in
                MainActor.shared.assertIsolated()
                return one + 1
            })
            .values {
            XCTAssertEqual(value, 2)
        }
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testBackgroundSharingSequence() async {
        func testBackgroundSharingSequence() async {
            for await value in await Observable.just(1)
                .asSharedSequence(
                    sharingStrategy: BackgroundSharingStrategy.self,
                    onErrorRecover: { _ in .empty() })
                    .map({ one in
                        if Thread.isMainThread {
                            return 0
                        }
                        return one + 1
                    })
                        .values {
                XCTAssertEqual(value, 2)
            }
        }
    }
}

private struct BackgroundSharingStrategy: SharingStrategyProtocol {
    public static var scheduler: SchedulerType { ConcurrentDispatchQueueScheduler(qos: .default) }

    public static func share<Element>(_ source: Observable<Element>) -> Observable<Element> {
        source.share(scope: .whileConnected)
    }
}

private typealias TestSequence<Element> = SharedSequence<BackgroundSharingStrategy, Element>
