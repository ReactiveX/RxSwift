//
//  Signal+Test.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/26/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import RxSwift
import RxCocoa
import XCTest
import RxTest

class SignalTests: SharedSequenceTest { }

extension SignalTests {
    func testSignalSharing_WhenErroring() {
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
        let signal = coldObservable.asSignal(onErrorJustReturn: -1)

        scheduler.scheduleAt(200) {
            disposable1 = signal.asObservable().subscribe(observer1)
        }

        scheduler.scheduleAt(225) {
            disposable2 = signal.asObservable().subscribe(observer2)
        }

        scheduler.scheduleAt(235) {
            disposable1.dispose()
        }

        scheduler.scheduleAt(260) {
            disposable2.dispose()
        }

        // resubscription

        scheduler.scheduleAt(260) {
            disposable3 = signal.asObservable().subscribe(observer3)
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

    func testSignalSharing_WhenCompleted() {
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
        let signal = coldObservable.asSignal(onErrorJustReturn: -1)


        scheduler.scheduleAt(200) {
            disposable1 = signal.asObservable().subscribe(observer1)
        }

        scheduler.scheduleAt(225) {
            disposable2 = signal.asObservable().subscribe(observer2)
        }

        scheduler.scheduleAt(235) {
            disposable1.dispose()
        }

        scheduler.scheduleAt(260) {
            disposable2.dispose()
        }

        // resubscription

        scheduler.scheduleAt(260) {
            disposable3 = signal.asObservable().subscribe(observer3)
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
extension SignalTests {
    func testPublishRelayAsSignal() {
        let hotObservable: PublishRelay<Int> = PublishRelay()
        let xs = Signal.zip(hotObservable.asSignal(), Signal.of(0, 0)) { x, _ in
            return x
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs, expectationFulfilled: { $0 == 2 }) {
            hotObservable.accept(1)
            hotObservable.accept(2)
        }

        XCTAssertEqual(results, [1, 2])
    }

    func testControlEventAsSignal() {
        let hotObservable: PublishRelay<Int> = PublishRelay()
        let controlEvent = ControlEvent(events: hotObservable.asObservable())
        let xs = Signal.zip(controlEvent.asSignal(), Signal.of(0, 0)) { x, _ in
            return x
        }

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs, expectationFulfilled: { $0 == 2 }) {
            hotObservable.accept(1)
            hotObservable.accept(2)
        }

        XCTAssertEqual(results, [1, 2])
    }

    func testAsSignal_onErrorJustReturn() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs = hotObservable.asSignal(onErrorJustReturn: -1)

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsSignal_onErrorDriveWith() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs = hotObservable.asSignal(onErrorSignalWith: Signal.just(-1))

        let results = subscribeTwiceOnBackgroundSchedulerAndOnlyOneSubscription(xs) {
            XCTAssertTrue(hotObservable.subscriptions == [SubscribedToHotObservable])

            hotObservable.on(.next(1))
            hotObservable.on(.next(2))
            hotObservable.on(.error(testError))

            XCTAssertTrue(hotObservable.subscriptions == [UnsunscribedFromHotObservable])
        }

        XCTAssertEqual(results, [1, 2, -1])
    }

    func testAsSignal_onErrorRecover() {
        let hotObservable = BackgroundThreadPrimitiveHotObservable<Int>()
        let xs = hotObservable.asSignal { _ in
            return Signal.empty()
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

// MARK: emit observer
extension SignalTests {
    func testEmitObserver() {
        var events: [Recorded<Event<Int>>] = []

        let observer: AnyObserver<Int> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = Signal.just(1).emit(to: observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }

    func testEmitOptionalObserver() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        _ = (Signal.just(1) as Signal<Int>).emit(to: observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }

    func testEmitNoAmbiguity() {
        var events: [Recorded<Event<Int?>>] = []

        let observer: AnyObserver<Int?> = AnyObserver { event in
            events.append(Recorded(time: 0, value: event))
        }

        // shouldn't cause compile time error
        _ = Signal.just(1).emit(to: observer)

        XCTAssertEqual(events.first?.value.element.flatMap { $0 }, 1)
    }
}

// MARK: emit behavior relay

extension SignalTests {
    func testEmitBehaviorRelay() {
        let relay = BehaviorRelay<Int>(value: 0)
        
        let subscription = (Signal.just(1) as Signal<Int>).emit(to: relay)
        
        XCTAssertEqual(relay.value, 1)
        subscription.dispose()
    }
    
    func testEmitBehaviorRelay1() {
        let relay = BehaviorRelay<Int?>(value: 0)
        
        let subscription = (Signal.just(1) as Signal<Int>).emit(to: relay)
        
        XCTAssertEqual(relay.value, 1)
        subscription.dispose()
    }
    
    func testEmitBehaviorRelay2() {
        let relay = BehaviorRelay<Int?>(value: 0)
        
        let subscription = (Signal.just(1) as Signal<Int?>).emit(to: relay)
        
        XCTAssertEqual(relay.value, 1)
        subscription.dispose()
    }
    
    func testEmitBehaviorRelay3() {
        let relay = BehaviorRelay<Int?>(value: 0)
        
        // shouldn't cause compile time error
        let subscription = Signal.just(1).emit(to: relay)
        
        XCTAssertEqual(relay.value, 1)
        subscription.dispose()
    }
}

// MARK: Emit to relay

extension SignalTests {
    func testSignalRelay() {
        let relay = PublishRelay<Int>()

        var latest: Int?
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Signal.just(1) as Signal<Int>).emit(to: relay)

        XCTAssertEqual(latest, 1)
    }

    func testSignalOptionalRelay1() {
        let relay = PublishRelay<Int?>()

        var latest: Int? = nil
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Signal.just(1) as Signal<Int>).emit(to: relay)

        XCTAssertEqual(latest, 1)
    }

    func testSignalOptionalRelay2() {
        let relay = PublishRelay<Int?>()

        var latest: Int?
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        _ = (Signal.just(1) as Signal<Int?>).emit(to: relay)

        XCTAssertEqual(latest, 1)
    }

    func testDriveRelayNoAmbiguity() {
        let relay = PublishRelay<Int?>()

        var latest: Int? = nil
        _ = relay.subscribe(onNext: { latestElement in
            latest = latestElement
        })

        // shouldn't cause compile time error
        _ = Signal.just(1).emit(to: relay)

        XCTAssertEqual(latest, 1)
    }
}
