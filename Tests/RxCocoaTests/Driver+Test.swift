//
//  Driver+Test.swift
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

class DriverTest : RxTest {
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
extension DriverTest {

    func subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription<R: Equatable>(_ driver: Driver<R>, subscribedOnBackground: () -> ()) -> [R] {
        var firstElements = [R]()
        var secondElements = [R]()

        let subscribeFinished = self.expectation(description: "subscribeFinished")

        var expectation1: XCTestExpectation!
        var expectation2: XCTestExpectation!

        _ = backgroundScheduler.schedule(()) { _ in
            var subscribing1 = true
            _ = driver.asObservable().subscribe { e in
                if !subscribing1 {
                    XCTAssertTrue(DispatchQueue.isMain)
                }
                switch e {
                case .next(let element):
                    firstElements.append(element)
                case .error(let error):
                    XCTFail("Error passed \(error)")
                case .completed:
                    expectation1.fulfill()
                }
            }
            subscribing1 = false

            var subscribing = true
            _ = driver.asDriver().asObservable().subscribe { e in
                if !subscribing {
                    XCTAssertTrue(DispatchQueue.isMain)
                }
                switch e {
                case .next(let element):
                    secondElements.append(element)
                case .error(let error):
                    XCTFail("Error passed \(error)")
                case .completed:
                    expectation2.fulfill()
                }
            }

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

        XCTAssertTrue(firstElements == secondElements)

        return firstElements
    }
}

// MARK: properties
extension DriverTest {
    func testDriverSharing_WhenErroring() {
        let scheduler = TestScheduler(initialClock: 0)

        let observer1 = scheduler.createObserver(Int.self)
        let observer2 = scheduler.createObserver(Int.self)
        let observer3 = scheduler.createObserver(Int.self)
        var disposable1: Disposable!
        var disposable2: Disposable!
        var disposable3: Disposable!

        let coldObservable = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            error(50, testError)
            ])
        let driver = coldObservable.asDriver(onErrorJustReturn: -1)

        scheduler.scheduleAt(200) {
            disposable1 = driver.asObservable().subscribe(observer1)
        }

        scheduler.scheduleAt(225) {
            disposable2 = driver.asObservable().subscribe(observer2)
        }

        scheduler.scheduleAt(235) {
            disposable1.dispose()
        }

        scheduler.scheduleAt(260) {
            disposable2.dispose()
        }

        // resubscription

        scheduler.scheduleAt(260) {
            disposable3 = driver.asObservable().subscribe(observer3)
        }

        scheduler.scheduleAt(285) {
            disposable3.dispose()
        }

        scheduler.start()

        XCTAssertEqual(observer1.events, [
            next(210, 0),
            next(220, 1),
            next(230, 2)
        ])

        XCTAssertEqual(observer2.events, [
            next(225, 1),
            next(230, 2),
            next(240, 3),
            next(250, -1),
            completed(250)
        ])

        XCTAssertEqual(observer3.events, [
            next(270, 0),
            next(280, 1),
        ])

        XCTAssertEqual(coldObservable.subscriptions, [
           Subscription(200, 250),
           Subscription(260, 285),
        ])
    }

    func testDriverSharing_WhenCompleted() {
        let scheduler = TestScheduler(initialClock: 0)

        let observer1 = scheduler.createObserver(Int.self)
        let observer2 = scheduler.createObserver(Int.self)
        let observer3 = scheduler.createObserver(Int.self)
        var disposable1: Disposable!
        var disposable2: Disposable!
        var disposable3: Disposable!

        let coldObservable = scheduler.createColdObservable([
            next(10, 0),
            next(20, 1),
            next(30, 2),
            next(40, 3),
            error(50, testError)
            ])
        let driver = coldObservable.asDriver(onErrorJustReturn: -1)


        scheduler.scheduleAt(200) {
            disposable1 = driver.asObservable().subscribe(observer1)
        }

        scheduler.scheduleAt(225) {
            disposable2 = driver.asObservable().subscribe(observer2)
        }

        scheduler.scheduleAt(235) {
            disposable1.dispose()
        }

        scheduler.scheduleAt(260) {
            disposable2.dispose()
        }

        // resubscription

        scheduler.scheduleAt(260) {
            disposable3 = driver.asObservable().subscribe(observer3)
        }

        scheduler.scheduleAt(285) {
            disposable3.dispose()
        }

        scheduler.start()

        XCTAssertEqual(observer1.events, [
            next(210, 0),
            next(220, 1),
            next(230, 2)
        ])

        XCTAssertEqual(observer2.events, [
            next(225, 1),
            next(230, 2),
            next(240, 3),
            next(250, -1),
            completed(250)
        ])

        XCTAssertEqual(observer3.events, [
            next(270, 0),
            next(280, 1),
        ])

        XCTAssertEqual(coldObservable.subscriptions, [
            Subscription(200, 250),
            Subscription(260, 285),
            ])
    }
}

// MARK: conversions
extension DriverTest {
    func testVariableAsDriver() {
        var hotObservable: Variable<Int>? = Variable(1)
        let driver = Driver.zip(hotObservable!.asDriver(), Driver.of(0, 0)) { all in
            return all.0
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            hotObservable?.value = 1
            hotObservable?.value = 2
            hotObservable = nil
        }

        XCTAssertEqual(results, [1, 1])
    }

    func testAsDriver_onErrorJustReturn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsDriver_onErrorDriveWith() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorDriveWith: Driver.just(-1))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsDriver_onErrorRecover() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver { e in
            return Driver.empty()
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2])
    }
}

// MARK: deferred
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
    func testAsDriver_switchLatest() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Driver<Int>>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()

        let driver = hotObservable.asDriver(onErrorJustReturn: hotObservable1.asDriver(onErrorJustReturn: -1)).switchLatest()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(hotObservable1.asDriver(onErrorJustReturn: -2)))

            hotObservable1.on(.next(1))
            hotObservable1.on(.next(2))
            hotObservable1.on(.error(testError))

            hotObservable.on(.next(hotObservable2.asDriver(onErrorJustReturn: -3)))

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
extension DriverTest {
    func testAsDriver_flatMapLatest() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()
        let errorHotObservable = MainThreadPrimitiveHotObservable<Int>()

        let drivers: [Driver<Int>] = [
            hotObservable1.asDriver(onErrorJustReturn: -2),
            hotObservable2.asDriver(onErrorJustReturn: -3),
            errorHotObservable.asDriver(onErrorJustReturn: -4),
        ]

        let driver = hotObservable.asDriver(onErrorJustReturn: 2).flatMapLatest { drivers[$0] }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
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
extension DriverTest {
    func testAsDriver_flatMapFirst() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let hotObservable1 = MainThreadPrimitiveHotObservable<Int>()
        let hotObservable2 = MainThreadPrimitiveHotObservable<Int>()
        let errorHotObservable = MainThreadPrimitiveHotObservable<Int>()

        let drivers: [Driver<Int>] = [
            hotObservable1.asDriver(onErrorJustReturn: -2),
            hotObservable2.asDriver(onErrorJustReturn: -3),
            errorHotObservable.asDriver(onErrorJustReturn: -4),
        ]

        let driver = hotObservable.asDriver(onErrorJustReturn: 2).flatMapFirst { drivers[$0] }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
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
extension DriverTest {
    func testAsDriver_doOn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()

        var events = [Event<Int>]()

        let driver = hotObservable.asDriver(onErrorJustReturn: -1).do(onNext: { e in
            XCTAssertTrue(DispatchQueue.isMain)

            events.append(.next(e))
        }, onCompleted: {
            XCTAssertTrue(DispatchQueue.isMain)
            events.append(.completed)
        }, onSubscribe: {
            XCTAssertTrue(!DispatchQueue.isMain)
        }, onDispose: {
            XCTAssertTrue(DispatchQueue.isMain)
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
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).do(onCompleted: { e in
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
extension DriverTest {
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
extension DriverTest {
    func testAsDriver_flatMap() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).flatMap { (n: Int) -> Driver<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Driver.just(n + 1)
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

// MARK: merge

extension DriverTest {
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
extension DriverTest {
    func testAsDriver_merge() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).map { (n: Int) -> Driver<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Driver.just(n + 1)
        }.merge()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(driver) {
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
        let driver = hotObservable.asDriver(onErrorJustReturn: -1).map { (n: Int) -> Driver<Int> in
            XCTAssertTrue(DispatchQueue.isMain)
            return Driver.just(n + 1)
        }.merge(maxConcurrent: 1)

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

// MARK: debug
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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
extension DriverTest {
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

//MARK: interval
extension DriverTest {
    func testAsDriver_interval() {
        let testScheduler = TestScheduler(initialClock: 0)

        let firstObserver = testScheduler.createObserver(Int.self)
        let secondObserver = testScheduler.createObserver(Int.self)

        var disposable1: Disposable!
        var disposable2: Disposable!

        driveOnScheduler(testScheduler) {
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
                next(120, 0),
                next(220, 1)
            ])
        XCTAssertEqual(secondObserver.events, [
                next(170, 0),
                next(220, 1)
            ])
    }
}

//MARK: timer
extension DriverTest {
    func testAsDriver_timer() {
        let testScheduler = TestScheduler(initialClock: 0)

        let firstObserver = testScheduler.createObserver(Int.self)
        let secondObserver = testScheduler.createObserver(Int.self)

        var disposable1: Disposable!
        var disposable2: Disposable!

        driveOnScheduler(testScheduler) {
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
            next(120, 0),
            next(225, 1)
            ])
        XCTAssertEqual(secondObserver.events, [
            next(170, 0),
            next(225, 1)
            ])
    }
}

// MARK: drive observer
extension DriverTest {
    func testDriveObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Driver.just(1).drive(observer)
    }

    func testDriveOptionalObserver() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Driver.just(1) as Driver<Int>).drive(observer)

        XCTAssertEqual(events[0].value.element!, 1)
    }

    func testDriveNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Driver.just(1).drive(observer)

        XCTAssertEqual(events[0].value.element!, 1)
    }
}

// MARK: drive variable

extension DriverTest {
    func testdriveVariable() {
        let variable = Variable<Int>(0)

        _ = Driver.just(1).drive(variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testDriveOptionalVariable() {
        let variable = Variable<Int?>(0)

        _ = (Driver.just(1) as Driver<Int>).drive(variable)

        XCTAssertEqual(variable.value, 1)
    }

    func testDriveVariableNoAmbiguity() {
        let variable = Variable<Int?>(0)

        _ = Driver.just(1).drive(variable)

        XCTAssertEqual(variable.value, 1)
    }
}

// MARK: from optional

extension DriverTest {
    func testDriverFromOptional() {
        let scheduler = TestScheduler(initialClock: 0)

        driveOnScheduler(scheduler) {
            let res = scheduler.start { Driver.from(optional: 1 as Int?).asObservable() }
            XCTAssertEqual(res.events, [
                next(201, 1),
                completed(202)
                ])
        }
    }

    func testDriverFromOptionalWhenNil() {
        let scheduler = TestScheduler(initialClock: 0)

        driveOnScheduler(scheduler) {
            let res = scheduler.start { Driver.from(optional: nil as Int?).asObservable() }
            XCTAssertEqual(res.events, [
                completed(201)
                ])
        }
    }
}


// MARK: from sequence

extension DriverTest {
    func testDriverFromSequence() {
        let scheduler = TestScheduler(initialClock: 0)

        driveOnScheduler(scheduler) {
            let res = scheduler.start { Driver.from(AnySequence([10])).asObservable() }
            XCTAssertEqual(res.events, [
                next(201, 10),
                completed(202)
                ])
        }
    }

    func testDriverFromArray() {
        let scheduler = TestScheduler(initialClock: 0)

        driveOnScheduler(scheduler) {
            let res = scheduler.start { Driver.from([20]).asObservable() }
            XCTAssertEqual(res.events, [
                next(201, 20),
                completed(202)
                ])
        }
    }
}

// MARK: correct order of sync subscriptions

extension DriverTest {
    func testDrivingOrderOfSynchronousSubscriptions1() {
        func prepareSampleDriver(with item: String) -> Driver<String> {
            return Observable.create { observer in
                    observer.onNext(item)
                    observer.onCompleted()
                    return Disposables.create()
                }
                .asDriver(onErrorJustReturn: "")
        }

        var disposeBag = DisposeBag()
        let scheduler = TestScheduler(initialClock: 0)
        let observer = scheduler.createObserver(String.self)
        let variable = Variable("initial")

        variable.asDriver()
            .drive(observer)
            .disposed(by: disposeBag)

        prepareSampleDriver(with: "first")
            .drive(variable)
            .disposed(by: disposeBag)

        prepareSampleDriver(with: "second")
            .drive(variable)
            .disposed(by: disposeBag)

        Observable.just("third")
            .bind(to: variable)
            .disposed(by: disposeBag)

        disposeBag = DisposeBag()

        XCTAssertEqual(observer.events, [
            next(0, "initial"),
            next(0, "first"),
            next(0, "second"),
            next(0, "third")
            ])

    }

    func testDrivingOrderOfSynchronousSubscriptions2() {
        var latestValue: Int?
        let state = Variable(1)
        _ = state.asDriver()
            .flatMapLatest { x in
                return Driver.just(x * 2)
            }
            .flatMapLatest { y in
                return Observable.just(y).asDriver(onErrorJustReturn: -1)
            }
            .flatMapLatest { y in
                return Observable.just(y).asDriver(onErrorDriveWith: Driver.empty())
            }
            .flatMapLatest { y in
                return Observable.just(y).asDriver(onErrorRecover: {  _ in Driver.empty() })
            }
            .drive(onNext: { element in
                latestValue = element
            })

        XCTAssertEqual(latestValue, 2)
    }
}
