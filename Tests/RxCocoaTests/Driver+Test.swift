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
import RxRelay
import XCTest
import RxTest

class DriverTest: SharedSequenceTest { }

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
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .next(40, 3),
            .error(50, testError)
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
            .next(210, 0),
            .next(220, 1),
            .next(230, 2)
        ])

        XCTAssertEqual(observer2.events, [
            .next(225, 1),
            .next(230, 2),
            .next(240, 3),
            .next(250, -1),
            .completed(250)
        ])

        XCTAssertEqual(observer3.events, [
            .next(270, 0),
            .next(280, 1),
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
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .next(40, 3),
            .completed(50)
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
            .next(210, 0),
            .next(220, 1),
            .next(230, 2)
        ])

        XCTAssertEqual(observer2.events, [
            .next(225, 1),
            .next(230, 2),
            .next(240, 3),
            .completed(250)
        ])

        XCTAssertEqual(observer3.events, [
            .next(270, 0),
            .next(280, 1),
        ])

        XCTAssertEqual(coldObservable.subscriptions, [
            Subscription(200, 250),
            Subscription(260, 285),
            ])
    }
}

// MARK: conversions
extension DriverTest {
    func testBehaviorRelayAsDriver() {
        let hotObservable: BehaviorRelay<Int> = BehaviorRelay(value: 0)
        let xs = Driver.zip(hotObservable.asDriver(), Driver.of(0, 0, 0)) { x, _ in
            return x
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs, expectationFulfilled: { $0 == 2 }) {
            hotObservable.accept(1)
            hotObservable.accept(2)
        }

        XCTAssertEqual(results, [0, 1, 2])
    }
    
    func testInfallibleAsDriver() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs = hotObservable.asInfallible(onErrorJustReturn: -1).asDriver()

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsDriver_onErrorJustReturn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs = hotObservable.asDriver(onErrorJustReturn: -1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
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
        let xs = hotObservable.asDriver(onErrorDriveWith: Driver.just(-1))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
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
        let xs = hotObservable.asDriver { _ in
            return Driver.empty()
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2])
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
        let relay = BehaviorRelay(value: "initial")

        relay.asDriver()
            .drive(observer)
            .disposed(by: disposeBag)

        prepareSampleDriver(with: "first")
            .drive(relay)
            .disposed(by: disposeBag)

        prepareSampleDriver(with: "second")
            .drive(relay)
            .disposed(by: disposeBag)

        Observable.just("third")
            .bind(to: relay)
            .disposed(by: disposeBag)

        disposeBag = DisposeBag()

        XCTAssertEqual(observer.events, [
            .next(0, "initial"),
            .next(0, "first"),
            .next(0, "second"),
            .next(0, "third")
            ])

    }

    func testDrivingOrderOfSynchronousSubscriptions2() {
        var latestValue: Int?
        let state = BehaviorSubject(value: 1)
        let subscription = state.asDriver(onErrorJustReturn: 0)
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
                return Observable.just(y).asDriver(onErrorRecover: { _ in Driver.empty() })
            }
            .drive(onNext: { element in
                latestValue = element
            })

        subscription.dispose()

        XCTAssertEqual(latestValue, 2)
    }
}


// MARK: drive observer
extension DriverTest {
    func testDriveObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Driver.just(1) as Driver<Int>).drive(observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }
    
    func testDriveObservers() {
        var events1: [Recorded<Event<Int>>] = []
        var events2: [Recorded<Event<Int>>] = []
        
        let observer1: AnyObserver<Int> = AnyObserver { event in
            events1.append(Recorded(time: 0, value: event))
        }
        
        let observer2: AnyObserver<Int> = AnyObserver { event in
            events2.append(Recorded(time: 0, value: event))
        }
        
        _ = (Driver.just(1) as Driver<Int>).drive(observer1, observer2)
        
        XCTAssertEqual(events1, [
            .next(1),
            .completed()
            ])
        
        XCTAssertEqual(events2, [
            .next(1),
            .completed()
            ])
    }

    func testDriveOptionalObserver() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Driver.just(1) as Driver<Int>).drive(observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }
    
    func testDriveOptionalObservers() {
        var events1: [Recorded<Event<Int?>>] = []
        var events2: [Recorded<Event<Int?>>] = []
        
        let observer1: AnyObserver<Int?> = AnyObserver { event in
            events1.append(Recorded(time: 0, value: event))
        }
        
        let observer2: AnyObserver<Int?> = AnyObserver { event in
            events2.append(Recorded(time: 0, value: event))
        }
        
        _ = (Driver.just(1) as Driver<Int>).drive(observer1, observer2)
        
        XCTAssertEqual(events1, [
            .next(1),
            .completed()
            ])
        
        XCTAssertEqual(events2, [
            .next(1),
            .completed()
            ])
    }

    func testDriveNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        // shouldn't cause compile time error
        _ = Driver.just(1).drive(observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }
}

// MARK: drive optional behavior relay

extension DriverTest {
    func testDriveBehaviorRelay() {
        let relay = BehaviorRelay<Int>(value: 0)
        
        let subscription = (Driver.just(1) as Driver<Int>).drive(relay)
        
        XCTAssertEqual(relay.value, 1)
        subscription.dispose()
    }
    
    func testDriveBehaviorRelays() {
        let relay1 = BehaviorRelay<Int>(value: 0)
        let relay2 = BehaviorRelay<Int>(value: 0)
        
        _ = Driver.just(1).drive(relay1, relay2)
        
        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }
    
    func testDriveOptionalBehaviorRelay1() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = (Driver.just(1) as Driver<Int>).drive(relay)

        XCTAssertEqual(relay.value, 1)
    }
    
    func testDriveOptionalBehaviorRelays1() {
        let relay1 = BehaviorRelay<Int?>(value: 0)
        let relay2 = BehaviorRelay<Int?>(value: 0)
        
        _ = (Driver.just(1) as Driver<Int>).drive(relay1, relay2)
        
        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }

    func testDriveOptionalBehaviorRelay2() {
        let relay = BehaviorRelay<Int?>(value: 0)

        _ = (Driver.just(1) as Driver<Int?>).drive(relay)

        XCTAssertEqual(relay.value, 1)
    }
    
    func testDriveOptionalBehaviorRelays2() {
        let relay1 = BehaviorRelay<Int?>(value: 0)
        let relay2 = BehaviorRelay<Int?>(value: 0)
        
        _ = (Driver.just(1) as Driver<Int?>).drive(relay1, relay2)
        
        XCTAssertEqual(relay1.value, 1)
        XCTAssertEqual(relay2.value, 1)
    }

    func testDriveBehaviorRelayNoAmbiguity() {
        let relay = BehaviorRelay<Int?>(value: 0)

        // shouldn't cause compile time error
        _ = Driver.just(1).drive(relay)

        XCTAssertEqual(relay.value, 1)
    }
}

// MARK: drive optional behavior relay
extension DriverTest {
    func testDriveReplayRelay() {
        let relay = ReplayRelay<Int>.create(bufferSize: 1)

        var latest: Int?
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Driver.just(1) as Driver<Int>).drive(relay)

        XCTAssertEqual(latest, 1)
    }

    func testDriveReplayRelays() {
        let relay1 = ReplayRelay<Int>.create(bufferSize: 1)
        let relay2 = ReplayRelay<Int>.create(bufferSize: 1)

        var latest1: Int?
        var latest2: Int?

        _ = relay1.subscribe(onNext: { latestElement in
            latest1 = latestElement
        })

        _ = relay2.subscribe(onNext: { latestElement in
            latest2 = latestElement
        })

        _ = (Driver.just(1) as Driver<Int>).drive(relay1, relay2)

        XCTAssertEqual(latest1, 1)
        XCTAssertEqual(latest2, 1)
    }

    func testDriveOptionalReplayRelay1() {
        let relay = ReplayRelay<Int?>.create(bufferSize: 1)

        var latest: Int? = nil
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Driver.just(1) as Driver<Int>).drive(relay)

        XCTAssertEqual(latest, 1)
    }

    func testDriveOptionalReplayRelays() {
        let relay1 = ReplayRelay<Int?>.create(bufferSize: 1)
        let relay2 = ReplayRelay<Int?>.create(bufferSize: 1)

        var latest1: Int?
        var latest2: Int?

        _ = relay1.subscribe(onNext: { latestElement in
            latest1 = latestElement
        })

        _ = relay2.subscribe(onNext: { latestElement in
            latest2 = latestElement
        })

        _ = (Driver.just(1) as Driver<Int>).drive(relay1, relay2)

        XCTAssertEqual(latest1, 1)
        XCTAssertEqual(latest2, 1)
    }

    func testDriveOptionalReplayRelay2() {
        let relay = ReplayRelay<Int?>.create(bufferSize: 1)

        var latest: Int?
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Driver.just(1) as Driver<Int?>).drive(relay)

        XCTAssertEqual(latest, 1)
    }

    func testDriveReplayRelays2() {
        let relay1 = ReplayRelay<Int?>.create(bufferSize: 1)
        let relay2 = ReplayRelay<Int?>.create(bufferSize: 1)

        var latest1: Int?
        var latest2: Int?

        _ = relay1.subscribe(onNext: { latestElement in
            latest1 = latestElement
        })

        _ = relay2.subscribe(onNext: { latestElement in
            latest2 = latestElement
        })

        _ = (Driver.just(1) as Driver<Int?>).drive(relay1, relay2)

        XCTAssertEqual(latest1, 1)
        XCTAssertEqual(latest2, 1)
    }

    func testDriveReplayRelayNoAmbiguity() {
        let relay = ReplayRelay<Int?>.create(bufferSize: 1)

        var latest: Int? = nil
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        // shouldn't cause compile time error
        _ = Driver.just(1).drive(relay)

        XCTAssertEqual(latest, 1)
    }
}

// MARK: - Drive with object
extension DriverTest {
    func testDriveWithNext() {
        var testObject: TestObject! = TestObject()
        let scheduler = TestScheduler(initialClock: 0)
        var values = [String]()
        var disposed: UUID?
        let coldObservable = scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .next(40, 3),
            .completed(50)
        ])
        
        let driver = coldObservable.asDriver(onErrorJustReturn: -1)
        
        _ = driver
            .drive(
                with: testObject,
                onNext: { object, value in values.append(object.id.uuidString + "\(value)") },
                onDisposed: { disposed = $0.id }
            )
        
        scheduler.start()
        
        let uuid = testObject.id
        XCTAssertEqual(values, [
            uuid.uuidString + "0",
            uuid.uuidString + "1",
            uuid.uuidString + "2",
            uuid.uuidString + "3"
        ])
        
        XCTAssertEqual(disposed, uuid)
        
        XCTAssertNotNil(testObject)
        testObject = nil
        XCTAssertNil(testObject)
    }
    
    func testDriveWithError() {
        var testObject: TestObject! = TestObject()
        let scheduler = TestScheduler(initialClock: 0)
        var values = [String]()
        var disposed: UUID?
        let coldObservable = scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .error(40, testError),
            .next(50, 3)
        ])
        
        let driver = coldObservable.asDriver(onErrorJustReturn: -1)
        
        _ = driver
            .drive(
                with: testObject,
                onNext: { object, value in values.append(object.id.uuidString + "\(value)") },
                onDisposed: { disposed = $0.id }
            )
        
        scheduler.start()
        
        let uuid = testObject.id
        XCTAssertEqual(values, [
            uuid.uuidString + "0",
            uuid.uuidString + "1",
            uuid.uuidString + "2",
            uuid.uuidString + "-1"
        ])
        
        XCTAssertEqual(disposed, uuid)
        
        XCTAssertNotNil(testObject)
        testObject = nil
        XCTAssertNil(testObject)
    }
    
    func testDriveWithCompleted() {
        var testObject: TestObject! = TestObject()
        let scheduler = TestScheduler(initialClock: 0)
        var values = [String]()
        var disposed: UUID?
        var completed: UUID?
        
        let coldObservable = scheduler.createColdObservable([
            .next(10, 0),
            .next(20, 1),
            .next(30, 2),
            .completed(40)
        ])
        
        let driver = coldObservable.asDriver(onErrorJustReturn: -1)
        
        _ = driver
            .drive(
                with: testObject,
                onNext: { object, value in values.append(object.id.uuidString + "\(value)") },
                onCompleted: { completed = $0.id },
                onDisposed: { disposed = $0.id  }
            )
        
        scheduler.start()
        
        let uuid = testObject.id
        XCTAssertEqual(values, [
            uuid.uuidString + "0",
            uuid.uuidString + "1",
            uuid.uuidString + "2"
        ])
        
        XCTAssertEqual(disposed, uuid)
        XCTAssertEqual(completed, uuid)
        
        XCTAssertNotNil(testObject)
        testObject = nil
        XCTAssertNil(testObject)
    }
}

private class TestObject: NSObject {
    var id = UUID()
}
