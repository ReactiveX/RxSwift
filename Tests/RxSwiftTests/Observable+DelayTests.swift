//
//  Observable+DelayTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import Dispatch

class ObservableDelayTest : RxTest {
}

extension ObservableDelayTest {
    
    func testDelay_TimeSpan_Simple1() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .completed(550)
            ])
    
        let res = scheduler.start {
            xs.delay(100, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events, [
            .next(350, 2),
            .next(450, 3),
            .next(550, 4),
            .completed(650)
            ])
    
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Simple2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .completed(550)
            ])
        
        let res = scheduler.start {
            xs.delay(50, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(300, 2),
            .next(400, 3),
            .next(500, 4),
            .completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Simple3() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .completed(550)
            ])
        
        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(400, 2),
            .next(500, 3),
            .next(600, 4),
            .completed(700)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }

    func testDelay_TimeSpan_Error() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
            ])

        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .error(250, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testDelay_TimeSpan_Completed() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])

        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }

        XCTAssertEqual(res.events, [
            .completed(400)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 250)
            ])
    }

    func testDelay_TimeSpan_Error1() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .error(550, testError)
            ])
    
        let res = scheduler.start {
            xs.delay(50, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events, [
            .next(300, 2),
            .next(400, 3),
            .next(500, 4),
            .error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Error2() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .error(550, testError)
            ])
        
        let res = scheduler.start {
            xs.delay(150, scheduler: scheduler)
        }
        
        XCTAssertEqual(res.events, [
            .next(400, 2),
            .next(500, 3),
            .error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
    }
    
    func testDelay_TimeSpan_Real_Simple() {
        let waitForError: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
    
        let res = s.delay(0.01, scheduler: scheduler)
    
        var array = [Int]()
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
            },
            onCompleted: {
                waitForError.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            s.onNext(2)
            s.onNext(3)
            s.onCompleted()
        }

        try! _ = waitForError.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1, 2, 3], array)
    }
    
    func testDelay_TimeSpan_Real_Error1() {
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()

        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()

        var error: Swift.Error? = nil
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
            },
            onError: { e in
                error = e
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            s.onNext(2)
            s.onNext(3)
            s.onError(testError)
        }

        try! errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()

        XCTAssertEqual(error! as! TestError, testError)
    }
    
    func testDelay_TimeSpan_Real_Error2() {
        let elementProcessed: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
        
        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()
        var err: TestError!
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
                elementProcessed.onCompleted()
            },
            onError: { ex in
                err = ex as! TestError
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            try! _ = elementProcessed.toBlocking(timeout: 5.0).first()
            s.onError(testError)
        }

        try! _ = errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1], array)
        XCTAssertEqual(testError, err)
    }


    func testDelay_TimeSpan_Real_Error3() {
        let elementProcessed: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let errorReceived: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let acknowledged: ReplaySubject<()> = ReplaySubject.create(bufferSize: 1)
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let s = PublishSubject<Int>()
        
        let res = s.delay(0.01, scheduler: scheduler)
        
        var array = [Int]()
        var err: TestError!
        
        let subscription = res.subscribe(
            onNext: { i in
                array.append(i)
                elementProcessed.onCompleted()
                try! _ = acknowledged.toBlocking(timeout: 5.0).first()
            },
            onError: { ex in
                err = ex as! TestError
                errorReceived.onCompleted()
        })
        
        DispatchQueue.global(qos: .default).async {
            s.onNext(1)
            try! _ = elementProcessed.toBlocking(timeout: 5.0).first()
            s.onError(testError)
            acknowledged.onCompleted()
        }

        try! _ = errorReceived.toBlocking(timeout: 5.0).first()
        
        subscription.dispose()
        
        XCTAssertEqual([1], array)
        XCTAssertEqual(testError, err)
    }
    
    func testDelay_TimeSpan_Positive() {
        let scheduler = TestScheduler(initialClock: 0)
    
        let msgs = Recorded.events(
            .next(150, 1),
            .next(250, 2),
            .next(350, 3),
            .next(450, 4),
            .completed(550)
        )
    
        let xs = scheduler.createHotObservable(msgs)
    
        let delay: RxTimeInterval = 42
        let res = scheduler.start {
            xs.delay(delay, scheduler: scheduler)
        }
    
        XCTAssertEqual(res.events,
            msgs.map { Recorded(time: $0.time + Int(delay), value: $0.value) }
                .filter { $0.time > 200 })
    }
    
    func testDelay_TimeSpan_DefaultScheduler() {
        let scheduler = MainScheduler.instance
        XCTAssertEqual(try! Observable.just(1).delay(0.001, scheduler: scheduler).toBlocking(timeout: 5.0).toArray(), [1])
    }

    #if TRACE_RESOURCES
        func testDelayReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).delay(100, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testDelayReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).delay(100, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
