//
//  SharedSequence+OperatorTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import RxSwift
import RxCocoa
import XCTest
import RxTest

class SharedSequenceOperatorTests : SharedSequenceTest { }

// MARK: deferred
extension SharedSequenceOperatorTests {
    func testAsDriver_deferred() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = Driver.deferred { hotObservable.asDriver(onErrorJustReturn: -1) }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }
}

// MARK: map
extension SharedSequenceOperatorTests {
    func testAsDriver_map() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).map { (n: Int) -> Int in
            XCTAssertTrue(DispatchQueue.isMain)
            return n + 1
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2, 3, 0])
    }
}

// MARK: filter
extension SharedSequenceOperatorTests {
    func testAsDriver_filter() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).filter { n in
            XCTAssertTrue(DispatchQueue.isMain)
            return n % 2 == 0
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2])
    }
}


// MARK: switch latest
extension SharedSequenceOperatorTests {
    func testAsDriver_switchLatest() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Signal<Int>>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()

        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: hotObservable1.asSignal(onErrorJustReturn: -1)).switchLatest()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(hotObservable1.asSignal(onErrorJustReturn: -2)))

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            hotObservable.on(.next(hotObservable2.asSignal(onErrorJustReturn: -3)))

            hotObservable2.on(.next(10))
            hotObservable2.on(.next(11))
            hotObservable2.on(.error(testError))

            hotObservable.on(.error(testError))

            hotObservable1.on(.completed)
            hotObservable.on(.completed)

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [
            1, 2, -2,
            10, 11, -3,
            -1
            ])
    }
}

// MARK: flatMapLatest
extension SharedSequenceOperatorTests {
    func testAsDriver_flatMapLatest() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()
        let errorHotObservable = MainThreadPrimitiveHotObservable<Int>()

        let signals: [Signal<Int>] = [
            hotObservable1.asSignal(onErrorJustReturn: -2),
            hotObservable2.asSignal(onErrorJustReturn: -3),
            errorHotObservable.asSignal(onErrorJustReturn: -4),
        ]

        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: 2).flatMapLatest { signals[$0] }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(0))

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            hotObservable.on(.next(1))

            hotObservable2.on(.next(10))
            hotObservable2.on(.next(11))
            hotObservable2.on(.error(testError))

            hotObservable.on(.error(testError))

            errorHotObservable.on(.completed)
            hotObservable.on(.completed)

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [
            1, 2, -2,
            10, 11, -3
            ])
    }
}

// MARK: flatMapFirst
extension SharedSequenceOperatorTests {
    func testAsDriver_flatMapFirst() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()
        let errorHotObservable = MainThreadPrimitiveHotObservable<Int>()

        let signals: [Signal<Int>] = [
            hotObservable1.asSignal(onErrorJustReturn: -2),
            hotObservable2.asSignal(onErrorJustReturn: -3),
            errorHotObservable.asSignal(onErrorJustReturn: -4),
        ]

        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: 2).flatMapFirst { signals[$0] }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(0))
            hotObservable.on(.next(1))

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            hotObservable2.on(.next(10))
            hotObservable2.on(.next(11))
            hotObservable2.on(.error(testError))

            hotObservable.on(.error(testError))

            errorHotObservable.on(.completed)
            hotObservable.on(.completed)

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [
            1, 2, -2,
            ])
    }
}

// MARK: doOn
extension SharedSequenceOperatorTests {
    func testAsDriver_doOn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        var events = [Event<Int>]()

        var calledSubscribe = false
        var calledSubscribed = false
        var calledDispose = false
        
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).do(onNext: { e in
            XCTAssertTrue(DispatchQueue.isMain)

            events.append(.next(e))
        }, onCompleted: {
            XCTAssertTrue(DispatchQueue.isMain)
            events.append(.completed)
        }, onSubscribe: {
            XCTAssertTrue(!DispatchQueue.isMain)
            calledSubscribe = true
        }, onSubscribed: {
            XCTAssertTrue(!DispatchQueue.isMain)
            calledSubscribed = true
        }, onDispose: {
            XCTAssertTrue(DispatchQueue.isMain)
            calledDispose = true
        })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
        let expectedEvents = [.next(1), .next(2), .next(-1), .completed] as [Event<Int>]
        XCTAssertEqual(events, expectedEvents)
        XCTAssertEqual(calledSubscribe, true)
        XCTAssertEqual(calledSubscribed, true)
        XCTAssertEqual(calledDispose, true)
    }


    func testAsDriver_doOnNext() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        var events = [Int]()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).do(onNext: { e in
            XCTAssertTrue(DispatchQueue.isMain)
            events.append(e)
        })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
        let expectedEvents = [1, 2, -1]
        XCTAssertEqual(events, expectedEvents)
    }

    func testAsDriver_doOnCompleted() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        var completed = false
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).do(onCompleted: {
            XCTAssertTrue(DispatchQueue.isMain)
            completed = true
        })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
        XCTAssertEqual(completed, true)
    }
}

// MARK: distinct until change
extension SharedSequenceOperatorTests {
    func testAsDriver_distinctUntilChanged1() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).distinctUntilChanged()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsDriver_distinctUntilChanged2() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).distinctUntilChanged({ $0 })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsDriver_distinctUntilChanged3() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).distinctUntilChanged({ $0 == $1 })

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }


    func testAsDriver_distinctUntilChanged4() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).distinctUntilChanged({ $0 }) { $0 == $1 }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

}

// MARK: flat map
extension SharedSequenceOperatorTests {
    func testAsDriver_flatMap() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: -1).flatMap { (n: Int) -> Signal<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Signal.just(n + 1)
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2, 3, 0])
    }

}

// MARK: merge

extension SharedSequenceOperatorTests {
    func testAsDriver_mergeSync() {
        let factories: [(Driver<Int>) -> Driver<Int>] =
            [
                { source in Driver.merge(source) },
                { source in Driver.merge([source]) },
                { source in Driver.merge(AnyCollection([source])) },
            ]

        for factory in factories {
            let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
            let driver = factory(hotObservable.asDriver(onErrorJustReturn: -1))

            let results = self.subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
                XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

                hotObservable.on(.next(1))
                hotObservable.on(.next(2))
                hotObservable.on(.error(testError))

                XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
            }

            XCTAssertEqual(results, [1, 2, -1])
        }
    }
}

// MARK: merge
extension SharedSequenceOperatorTests {
    func testAsDriver_merge() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: -1).map { (n: Int) -> Signal<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Signal.just(n + 1)
        }.merge()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2, 3, 0])
    }

    func testAsDriver_merge2() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs: Signal<Int> = hotObservable.asDriver(onErrorJustReturn: -1).map { (n: Int) -> Signal<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Signal.just(n + 1)
        }.merge(maxConcurrent: 1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2, 3, 0])
    }
}

// MARK: debug
extension SharedSequenceOperatorTests {
    func testAsDriver_debug() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).debug("a", trimOutput: false)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, -1])
    }
}

// MARK: debounce
extension SharedSequenceOperatorTests {
    func testAsDriver_debounce() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).debounce(0.0)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [-1])
    }

    func testAsDriver_throttle() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).throttle(0.5)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, -1])
    }

    func testAsDriver_throttle2() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).throttle(0.5, latest: false)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1])
    }

}

// MARK: scan
extension SharedSequenceOperatorTests {
    func testAsDriver_scan() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).scan(0) { (a: Int, n: Int) -> Int in
            XCTAssertTrue(DispatchQueue.isMain)
            return a + n
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 3, 2])
    }

}

// MARK: concat
extension SharedSequenceOperatorTests {
    func testAsDriver_concat_sequenceType() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()

        let driver = Driver.concat(AnySequence([hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2)]))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

            hotObservable2.on(.next(4))
            hotObservable2.on(.next(5))
            hotObservable2.on(.error(testError))

            XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1, 4, 5, -2])
    }

    func testAsDriver_concat() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()

        let driver = Driver.concat([hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2)])

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

            hotObservable2.on(.next(4))
            hotObservable2.on(.next(5))
            hotObservable2.on(.error(testError))

            XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1, 4, 5, -2])
    }
}

// MARK: combine latest
extension SharedSequenceOperatorTests {
    func testAsDriver_combineLatest_array() {
        let factories: [([Driver<Int>]) -> Driver<Int>] =
            [
                { e0 in
                    Driver.combineLatest(e0) { a in a.reduce(0, +) }
                },
                { e0 in
                    Driver.combineLatest(e0).map { a in a.reduce(0, +) }
                },
            ]

        for factory in factories {
            let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
            let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

            let driver = factory([hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2)])

            let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
                XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

                hotObservable1.on(.next(1))
                hotObservable2.on(.next(4))

                hotObservable1.on(.next(2))
                hotObservable2.on(.next(5))

                hotObservable1.on(.error(testError))
                hotObservable2.on(.error(testError))

                XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
            }

            XCTAssertEqual(results, [5, 6, 7, 4, -3])
        }
    }

    func testAsDriver_combineLatest() {
        let factories: [(Driver<Int>, Driver<Int>) -> Driver<Int>] =
            [
                { e0, e1 in
                    Driver.combineLatest(e0, e1, resultSelector: +)
                },
                { e0, e1 in
                    Driver.combineLatest(e0, e1).map(+)
                },
            ]
        for factory in factories {
            let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
            let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

            let driver = factory(hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2))

            let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
                XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

                hotObservable1.on(.next(1))
                hotObservable2.on(.next(4))

                hotObservable1.on(.next(2))
                hotObservable2.on(.next(5))

                hotObservable1.on(.error(testError))
                hotObservable2.on(.error(testError))

                XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
            }

            XCTAssertEqual(results, [5, 6, 7, 4, -3])
        }
    }
}

// MARK: zip
extension SharedSequenceOperatorTests {
    func testAsDriver_zip_array() {
        let factories: [([Driver<Int>]) -> Driver<Int>] =
            [
                { e0 in
                    Driver.zip(e0) { a in a.reduce(0, +) }
                },
                { e0 in
                    Driver.zip(e0).map { a in a.reduce(0, +) }
                },
            ]

        for factory in factories {
            let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
            let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

            let driver = factory([hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2)])

            let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
                XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

                hotObservable1.on(.next(1))
                hotObservable2.on(.next(4))

                hotObservable1.on(.next(2))
                hotObservable2.on(.next(5))

                hotObservable1.on(.error(testError))
                hotObservable2.on(.error(testError))

                XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
            }

            XCTAssertEqual(results, [5, 7, -3])
        }
    }

    func testAsDriver_zip() {
        let factories: [(Driver<Int>, Driver<Int>) -> Driver<Int>] =
            [
                { e0, e1 in
                    Driver.zip(e0, e1, resultSelector: +)
                },
                { e0, e1 in
                    Driver.zip(e0, e1).map(+)
                },
            ]
        for factory in factories {
            let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
            let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

            let driver = factory(hotObservable1.asDriver(onErrorJustReturn: -1), hotObservable2.asDriver(onErrorJustReturn: -2))

            let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
                XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

                hotObservable1.on(.next(1))
                hotObservable2.on(.next(4))

                hotObservable1.on(.next(2))
                hotObservable2.on(.next(5))

                hotObservable1.on(.error(testError))
                hotObservable2.on(.error(testError))

                XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
                XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
            }

            XCTAssertEqual(results, [5, 7, -3])
        }
    }
}

// MARK: withLatestFrom
extension SharedSequenceOperatorTests {
    func testAsDriver_withLatestFrom() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable1.asDriver(onErrorJustReturn: -1).withLatestFrom(hotObservable2.asDriver(onErrorJustReturn: -2)) { f, s in "\(f)\(s)" }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable2.on(.next(4))

            hotObservable1.on(.next(2))
            hotObservable2.on(.next(5))

            hotObservable1.on(.error(testError))
            hotObservable2.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, ["24", "-15"])
    }

    func testAsDriver_withLatestFromDefaultOverload() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable1.asDriver(onErrorJustReturn: -1).withLatestFrom(hotObservable2.asDriver(onErrorJustReturn: -2))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable2.on(.next(4))

            hotObservable1.on(.next(2))
            hotObservable2.on(.next(5))

            hotObservable1.on(.error(testError))
            hotObservable2.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
            XCTAssertTrue(hotObservable2.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [4, 5])

    }
}

// MARK: skip
extension SharedSequenceOperatorTests {
    func testAsDriver_skip() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable1.asDriver(onErrorJustReturn: -1).skip(1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))

            hotObservable1.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [2, -1])
    }
}

// MARK: startWith
extension SharedSequenceOperatorTests {
    func testAsDriver_startWith() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable1.asDriver(onErrorJustReturn: -1).startWith(0)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))

            hotObservable1.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [0, 1, 2, -1])
    }
}

// MARK: delay
extension SharedSequenceOperatorTests {
    func testAsDriver_delay() {
        let hotObservable1 = BackgroundThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable1.asDriver(onErrorJustReturn: -1).delay(0.1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable1.subscriptions == [SubscribedToHotObservable])

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))

            hotObservable1.on(.error(testError))

            XCTAssertTrue(hotObservable1.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }
}

// MARK: interval
extension SharedSequenceOperatorTests {
    func testAsDriver_interval() {
        let testScheduler = TestScheduler(initialClock: 0)

        let firstObserver = testScheduler.createObserver(Int.self)
        let secondObserver = testScheduler.createObserver(Int.self)

        var disposable1: Disposable!
        var disposable2: Disposable!

        SharingScheduler.mock(scheduler: testScheduler) {
            let interval = Driver<Int>.interval(100)

            testScheduler.scheduleAt(20) {
                disposable1 = interval.asObservable().subscribe(firstObserver)
            }

            testScheduler.scheduleAt(170) {
                disposable2 = interval.asObservable().subscribe(secondObserver)
            }

            testScheduler.scheduleAt(230) {
                disposable1.dispose()
                disposable2.dispose()
            }

            testScheduler.start()
        }

        XCTAssertEqual(firstObserver.events, [
                .next(120, 0),
                .next(220, 1)
            ])
        XCTAssertEqual(secondObserver.events, [
                .next(170, 0),
                .next(220, 1)
            ])
    }
}

// MARK: timer
extension SharedSequenceOperatorTests {
    func testAsDriver_timer() {
        let testScheduler = TestScheduler(initialClock: 0)

        let firstObserver = testScheduler.createObserver(Int.self)
        let secondObserver = testScheduler.createObserver(Int.self)

        var disposable1: Disposable!
        var disposable2: Disposable!

        SharingScheduler.mock(scheduler: testScheduler) {
            let interval = Driver<Int>.timer(100, period: 105)

            testScheduler.scheduleAt(20) {
                disposable1 = interval.asObservable().subscribe(firstObserver)
            }

            testScheduler.scheduleAt(170) {
                disposable2 = interval.asObservable().subscribe(secondObserver)
            }

            testScheduler.scheduleAt(230) {
                disposable1.dispose()
                disposable2.dispose()
            }

            testScheduler.start()
        }

        XCTAssertEqual(firstObserver.events, [
            .next(120, 0),
            .next(225, 1)
            ])
        XCTAssertEqual(secondObserver.events, [
            .next(170, 0),
            .next(225, 1)
            ])
    }
}

// MARK: from optional

extension SharedSequenceOperatorTests {
    func testDriverFromOptional() {
        let scheduler = TestScheduler(initialClock: 0)

        SharingScheduler.mock(scheduler: scheduler) {
            let res = scheduler.start { Driver.from(optional: 1 as Int?).asObservable() }
            XCTAssertEqual(res.events, [
                .next(201, 1),
                .completed(202)
                ])
        }
    }

    func testDriverFromOptionalWhenNil() {
        let scheduler = TestScheduler(initialClock: 0)

        SharingScheduler.mock(scheduler: scheduler) {
            let res = scheduler.start { Driver.from(optional: nil as Int?).asObservable() }
            XCTAssertEqual(res.events, [
                .completed(201)
                ])
        }
    }
}


// MARK: from sequence

extension SharedSequenceOperatorTests {
    func testDriverFromSequence() {
        let scheduler = TestScheduler(initialClock: 0)

        SharingScheduler.mock(scheduler: scheduler) {
            let res = scheduler.start { Driver.from(AnySequence([10])).asObservable() }
            XCTAssertEqual(res.events, [
                .next(201, 10),
                .completed(202)
                ])
        }
    }

    func testDriverFromArray() {
        let scheduler = TestScheduler(initialClock: 0)

        SharingScheduler.mock(scheduler: scheduler) {
            let res = scheduler.start { Driver.from([20]).asObservable() }
            XCTAssertEqual(res.events, [
                .next(201, 20),
                .completed(202)
                ])
        }
    }
}
