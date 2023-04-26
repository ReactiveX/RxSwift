//
//  Observable+MergeTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableMergeTest : RxTest {
}

extension ObservableMergeTest {
    func testMerge_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
        ).merge()
        
        _ = observable.subscribe(onNext: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMerge_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.concat([Observable.of(0, 1), Observable.error(testError)]),
            Observable.of(0, 1, 2)
        ).merge()
        
        _ = observable.subscribe(onError: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockErrorImmediately() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge()

        _ = observable.subscribe(onError: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable<Observable<Int>>.empty().merge()
        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable.just(Observable.empty()).merge()
        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        _ = observable.subscribe(onNext: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 9)
    }
    
    func testMergeConcurrent_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.concat([Observable.of(0, 1), Observable.error(testError)]),
            Observable.of(0, 1, 2)
        ).merge(maxConcurrent: 1)
        
        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockErrorImmediately() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge(maxConcurrent: 1)

        _ = observable.subscribe(onError: { _ in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable<Observable<Int>>.empty().merge(maxConcurrent: 1)

        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMergeConcurrent_DeadlockFirstEmpty() {
        var nEvents = 0
        
        let observable: Observable<Int> = Observable.just(Observable.empty()).merge(maxConcurrent: 1)

        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_ObservableOfObservable_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .next(120, 305),
            .completed(150)
        ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(500, ys3),
            .completed(600)
        ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 103),
            .next(410, 201),
            .next(420, 104),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .next(510, 105),
            .next(510, 301),
            .next(520, 106),
            .next(520, 302),
            .next(530, 303),
            .next(540, 304),
            .next(620, 305),
            .completed(650)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 530),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(500, 650),
            ])
    }
    
    func testMerge_ObservableOfObservable_Data_NotOverlapped() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(50)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(500, ys3),
            .completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 201),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .next(510, 301),
            .next(520, 302),
            .next(530, 303),
            .next(540, 304),
            .completed(600)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 530),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(500, 550),
            ])
    }
    
    func testMerge_ObservableOfObservable_InnerThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .error(50, testError1)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(20, 302),
            .next(30, 303),
            .next(40, 304),
            .completed(150)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(500, ys3),
            .completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 103),
            .next(410, 201),
            .next(420, 104),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(450, testError1)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 450),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            ])
    }
    
    func testMerge_ObservableOfObservable_OuterThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 101),
            .next(20, 102),
            .next(110, 103),
            .next(120, 104),
            .next(210, 105),
            .next(220, 106),
            .completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(10, 201),
            .next(20, 202),
            .next(30, 203),
            .next(40, 204),
            .completed(50)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .error(500, testError1),
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = Recorded.events(
            .next(310, 101),
            .next(320, 102),
            .next(410, 103),
            .next(410, 201),
            .next(420, 104),
            .next(420, 202),
            .next(430, 203),
            .next(440, 204),
            .error(500, testError1)
        )

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 500),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 500),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(400, 450),
            ])
    }
    
    func testMerge_MergeConcat_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(320, ys4),
            .completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 6),
            .next(440, 7),
            .next(460, 8),
            .next(670, 9),
            .next(700, 10),
            .completed(760)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 460),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 480),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(460, 760),
            ])
    }
    
    func testMerge_MergeConcat_BasicLong() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(320, ys4),
            .completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 6),
            .next(440, 7),
            .next(460, 8),
            .next(690, 9),
            .next(720, 10),
            .completed(780)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 480),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(480, 780),
            ])
    }
    
    func testMerge_MergeConcat_BasicWide() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(420, ys4),
            .completed(450)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(280, 6),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 7),
            .next(380, 8),
            .next(630, 9),
            .next(660, 10),
            .completed(720)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 450),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(270, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(420, 720),
            ])
    }
    
    func testMerge_MergeConcat_BasicLate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(420, ys4),
            .completed(750)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(280, 6),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 7),
            .next(380, 8),
            .next(630, 9),
            .next(660, 10),
            .completed(750)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 750),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 560),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(270, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(420, 720),
            ])
    }
    
    func testMerge_MergeConcat_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(320, ys4),
            .completed(400)
            ])
        
        let res = scheduler.start(disposed: 450) {
            xs.merge(maxConcurrent: 2)
        }

        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 6),
            .next(440, 7)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 450),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 450),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            ])
    }
    
    func testMerge_MergeConcat_OuterError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(320, ys4),
            .error(400, testError1)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 6),
            .error(400, testError1)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 400),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 400),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            ])
    }
    
    func testMerge_MergeConcat_InnerError() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(50, 1),
            .next(100, 2),
            .next(120, 3),
            .completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(20, 4),
            .next(70, 5),
            .completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(90, 7),
            .next(110, 8),
            .error(140, testError1)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .next(210, 9),
            .next(240, 10),
            .completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(210, ys1),
            .next(260, ys2),
            .next(270, ys3),
            .next(320, ys4),
            .completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = Recorded.events(
            .next(260, 1),
            .next(280, 4),
            .next(310, 2),
            .next(330, 3),
            .next(330, 5),
            .next(360, 6),
            .next(440, 7),
            .next(460, 8),
            .error(490, testError1)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 400),
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(210, 350),
            ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(260, 460),
            ])
        
        XCTAssertEqual(ys3.subscriptions, [
            Subscription(350, 490),
            ])
        
        XCTAssertEqual(ys4.subscriptions, [
            Subscription(460, 490),
            ])
    }

    #if TRACE_RESOURCES
        func testMerge1ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1).delay(.seconds(10), scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1))
                .concat(Observable<Int>.timer(.seconds(20), scheduler: scheduler).flatMapLatest { _ in return Observable<Observable<Int>>.empty() })
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.never().timeout(.seconds(10), scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1))
                .concat(Observable.never().timeout(.seconds(20), scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }
    #endif
}

extension ObservableMergeTest {
    func testMergeSync_Empty() {
        let factories: [() -> Observable<Int>] =
            [
                { Observable.merge() },
                { Observable.merge(AnyCollection([])) },
                { Observable.merge([]) },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let res = scheduler.start(factory)

            let messages = [
                Recorded.completed(200, Int.self)
            ]

            XCTAssertEqual(res.events, messages)
        }
    }

    func testMergeSync_EmptyData_DoesntCompleteImmediately() {
        let factories: [(Observable<Int>, Observable<Int>) -> Observable<Int>] =
            [
                { ys1, ys2 in Observable.merge(ys1, ys2) },
                { ys1, ys2 in Observable.merge(AnyCollection([ys1, ys2])) },
                { ys1, ys2 in Observable.merge([ys1, ys2]) },
                ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = Observable<Int>.empty()

            let ys2 = scheduler.createColdObservable([
                .next(10, 201),
                .next(20, 202),
                .completed(50)
                ])

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable())
            }

            let messages = Recorded.events(
                .next(210, 201),
                .next(220, 202),
                .completed(250)
            )

            XCTAssertEqual(res.events, messages)

            XCTAssertEqual(ys2.subscriptions, [
                Subscription(200, 250),
                ])
        }
    }

    func testMergeSync_EmptyEmpty_Completes() {
        let factories: [(Observable<Int>, Observable<Int>) -> Observable<Int>] =
            [
                { ys1, ys2 in Observable.merge(ys1, ys2) },
                { ys1, ys2 in Observable.merge(AnyCollection([ys1, ys2])) },
                { ys1, ys2 in Observable.merge([ys1, ys2]) },
                ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = Observable<Int>.empty()

            let ys2 = Observable<Int>.empty()

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable())
            }

            let messages = [
                Recorded.completed(200, Int.self)
            ]

            XCTAssertEqual(res.events, messages)
        }
    }
    
    func testMergeSync_Data() {
        let factories: [(Observable<Int>, Observable<Int>, Observable<Int>) -> Observable<Int>] =
            [
                { ys1, ys2, ys3 in Observable.merge(ys1, ys2, ys3) },
                { ys1, ys2, ys3 in Observable.merge(AnyCollection([ys1, ys2, ys3])) },
                { ys1, ys2, ys3 in Observable.merge([ys1, ys2, ys3]) },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = scheduler.createColdObservable([
                .next(10, 101),
                .next(20, 102),
                .completed(230)
                ])

            let ys2 = scheduler.createColdObservable([
                .next(10, 201),
                .next(20, 202),
                .completed(50)
                ])

            let ys3 = scheduler.createColdObservable([
                .next(10, 301),
                .next(20, 302),
                .completed(150)
                ])

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable(), ys3.asObservable())
            }

            let messages = Recorded.events(
                .next(210, 101),
                .next(210, 201),
                .next(210, 301),
                .next(220, 102),
                .next(220, 202),
                .next(220, 302),
                .completed(430)
            )

            XCTAssertEqual(res.events, messages)

            XCTAssertEqual(ys1.subscriptions, [
                Subscription(200, 430),
                ])

            XCTAssertEqual(ys2.subscriptions, [
                Subscription(200, 250),
                ])

            XCTAssertEqual(ys3.subscriptions, [
                Subscription(200, 350),
                ])
        }
    }

    func testMergeSync_ObservableOfObservable_InnerThrows() {
        let factories: [(Observable<Int>, Observable<Int>, Observable<Int>) -> Observable<Int>] =
            [
                { ys1, ys2, ys3 in Observable.merge(ys1, ys2, ys3) },
                { ys1, ys2, ys3 in Observable.merge(AnyCollection([ys1, ys2, ys3])) },
                { ys1, ys2, ys3 in Observable.merge([ys1, ys2, ys3]) },
            ]
        for factory in factories {
            let scheduler = TestScheduler(initialClock: 0)

            let ys1 = scheduler.createColdObservable([
                .next(10, 101),
                .next(20, 102),
                .completed(230)
                ])

            let ys2 = scheduler.createColdObservable([
                .next(10, 201),
                .error(15, testError)
                ])

            let ys3 = scheduler.createColdObservable([
                .next(10, 301),
                .next(20, 302),
                .completed(150)
                ])

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable(), ys3.asObservable())
            }

            let messages = Recorded.events(
                .next(210, 101),
                .next(210, 201),
                .next(210, 301),
                .error(215, testError)
            )

            XCTAssertEqual(res.events, messages)

            XCTAssertEqual(ys1.subscriptions, [
                Subscription(200, 215),
                ])

            XCTAssertEqual(ys2.subscriptions, [
                Subscription(200, 215),
                ])

            XCTAssertEqual(ys3.subscriptions, [
                Subscription(200, 215),
                ])
        }
    }

    #if TRACE_RESOURCES
        func testMergeSyncReleasesResourcesOnComplete() {
            _ = Observable.merge(Observable.just(1))
                .subscribe()

            _ = Observable.merge([Observable.just(1)])
                .subscribe()

            _ = Observable.merge(AnyCollection([Observable.just(1)]))
                .subscribe()
        }
    
        func testMergeSyncReleasesResourcesOnError() {
            _ = Observable.merge(Observable<Int>.error(testError))
                .subscribe()

            _ = Observable.merge([Observable<Int>.error(testError)])
                .subscribe()

            _ = Observable.merge(AnyCollection([Observable<Int>.error(testError)]))
                .subscribe()
        }

    #endif
}


extension ObservableMergeTest {

    func testFlatMapFirst_Complete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
            ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
            ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
            ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
            ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
            ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
            ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
            ])),
            .completed(900)
        ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(930, 401),
            .next(940, 402),
            .completed(950)
        ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
        ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
        ])
    }


    func testFlatMapFirst_Complete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(930, 401),
            .next(940, 402),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }

    func testFlatMapFirst_Complete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(930, 401),
            .next(940, 402),
            .completed(950),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }


    func testFlatMapFirst_Complete_ErrorOuter() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .error(900, testError)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .error(900, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 900)
            ])
    }

    func testFlatMapFirst_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .error(460, testError)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .error(760, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }

    func testFlatMapFirst_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])

        let res = scheduler.start(disposed: 700) {
            xs.flatMapFirst { $0 }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 700)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 700)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [])
    }

    func testFlatMapFirst_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])

        var invoked = 0
        let res = scheduler.start {
            return xs.flatMapFirst { (x: TestableObservable<Int>) -> TestableObservable<Int> in
                invoked += 1
                if invoked == 2 {
                    throw testError
                }
                return x
            }
        }

        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .error(850, testError)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 850)
            ])

        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [])
    }

    func testFlatMapFirst_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)

        let xs = scheduler.createHotObservable([
            .next(210, 4),
            .next(220, 3),
            .next(250, 5),
            .next(270, 1),
            .completed(290)
            ])

        let res = scheduler.start {
            xs.flatMapFirst { x in
                return Observable<Int64>.interval(.seconds(10), scheduler: scheduler).map { _ in x } .take(x)
            }
        }

        XCTAssertEqual(res.events, [
            .next(220, 4),
            .next(230, 4),
            .next(240, 4),
            .next(250, 4),
            .next(280, 1),
            .completed(290)
            ])

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
    }

    #if TRACE_RESOURCES
        func testFlatMapFirstReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).flatMapFirst { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMapFirst1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).flatMapFirst { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMapFirst2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMapFirst { _ -> Observable<Int> in throw testError }.subscribe()
        }

        func testFlatMapFirst3ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMapFirst { _ -> Observable<Int> in Observable.error(testError) }.subscribe()
        }
    #endif
}

// MARK: flatMap
extension ObservableMergeTest {
    
    func testFlatMap_Complete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
            ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
            ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
            ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
            ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
            ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
            ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
            ])),
            .completed(900)
        ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            .next(740, 106),
            .next(810, 304),
            .next(860, 305),
            .next(930, 401),
            .next(940, 402),
            .completed(960)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])

    
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
        ])

        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
        ])

        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
        ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
        ])

        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
        ])
    }
    
    func testFlatMap_Complete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            .next(740, 106),
            .next(810, 304),
            .next(860, 305),
            .next(930, 401),
            .next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    func testFlatMap_Complete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            .next(740, 106),
            .next(810, 304),
            .next(860, 305),
            .next(930, 401),
            .next(940, 402),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 1000)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 960)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 950)
            ])
    }
    
    func testFlatMap_Complete_ErrorOuter() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .error(900, testError)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            .next(740, 106),
            .next(810, 304),
            .next(860, 305),
            .error(900, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 900)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 790)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            Subscription(850, 900)
            ])
    }
    
    func testFlatMap_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .error(460, testError)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])
        
        let res = scheduler.start {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            .next(740, 106),
            .error(760, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            Subscription(750, 760)
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMap_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])
        
        let res = scheduler.start(disposed: 700) {
            xs.flatMap { $0 }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(560, 301),
            .next(580, 202),
            .next(590, 203),
            .next(600, 302),
            .next(620, 303),
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 605)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            Subscription(550, 700)
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
   
    func testFlatMap_SelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            .next(5, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(105, scheduler.createColdObservable([
                .error(1, testError)
                ])),
            .next(300, scheduler.createColdObservable([
                .next(10, 102),
                .next(90, 103),
                .next(110, 104),
                .next(190, 105),
                .next(440, 106),
                .completed(460)
                ])),
            .next(400, scheduler.createColdObservable([
                .next(180, 202),
                .next(190, 203),
                .completed(205)
                ])),
            .next(550, scheduler.createColdObservable([
                .next(10, 301),
                .next(50, 302),
                .next(70, 303),
                .next(260, 304),
                .next(310, 305),
                .completed(410)
                ])),
            .next(750, scheduler.createColdObservable([
                .completed(40)
                ])),
            .next(850, scheduler.createColdObservable([
                .next(80, 401),
                .next(90, 402),
                .completed(100)
                ])),
            .completed(900)
            ])
        
        var invoked = 0
        let res = scheduler.start {
            return xs.flatMap { (x: TestableObservable<Int>) -> TestableObservable<Int> in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return x
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .error(550, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[2].value.element!.subscriptions, [
            Subscription(300, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[3].value.element!.subscriptions, [
            Subscription(400, 550)
            ])
        
        XCTAssertEqual(xs.recordedEvents[4].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[5].value.element!.subscriptions, [
            ])
        
        XCTAssertEqual(xs.recordedEvents[6].value.element!.subscriptions, [
            ])
    }
    
    func testFlatMap_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(210, 4),
            .next(220, 3),
            .next(250, 5),
            .next(270, 1),
            .completed(290)
            ])
        
        let res = scheduler.start {
            xs.flatMap { x in
                return Observable<Int64>.interval(.seconds(10), scheduler: scheduler).map { _ in x } .take(x)
            }
        }
        
        XCTAssertEqual(res.events, [
            .next(220, 4),
            .next(230, 3),
            .next(230, 4),
            .next(240, 3),
            .next(240, 4),
            .next(250, 3),
            .next(250, 4),
            .next(260, 5),
            .next(270, 5),
            .next(280, 1),
            .next(280, 5),
            .next(290, 5),
            .next(300, 5),
            .completed(300)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
            ])
    }

    #if TRACE_RESOURCES
        func testFlatMapReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).flatMap { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMap1ReleasesResourcesOnError() {
            _ = Observable<Int>.error(testError).flatMap { _ in Observable.just(1) }.subscribe()
        }

        func testFlatMap2ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMap { _ -> Observable<Int> in throw testError }.subscribe()
        }

        func testFlatMap3ReleasesResourcesOnError() {
            _ = Observable<Int>.just(1).flatMap { _ -> Observable<Int> in Observable.error(testError) }.subscribe()
        }
    #endif
}

// MARK: concatMap

extension ObservableMergeTest {

    func testConcatMap_InnerCompleteFasterThanOuterElementsAreProduced() {
        
        let scheduler = TestScheduler(initialClock: 0)

        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .completed(20)
            ])

        let ys2 = scheduler.createColdObservable([
            .next(20, 202),
            .completed(25)
            ])

        let xs = scheduler.createHotObservable([
            .next(250, ys1),
            .next(300, ys2),
            .completed(900)
            ])

        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
            ])

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(250, 270)
            ])

        XCTAssertEqual(ys2.subscriptions, [
            Subscription(300, 325)
            ])

        XCTAssertEqual(results.events, [
            .next(260, 102),
            .next(320, 202),
            .completed(900)
            ])
    }

    func testConcatMap_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)

        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .completed(20)
            ])

        let ys2 = scheduler.createColdObservable([
            .next(20, 202),
            .completed(25)
            ])

        let xs = scheduler.createHotObservable([
            .next(250, ys1),
            .next(300, ys2),
            .completed(900)
            ])

        let results = scheduler.start(disposed: 310) {
            return xs.concatMap {
                return $0
            }
        }

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 310)
            ])

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(250, 270)
            ])

        XCTAssertEqual(ys2.subscriptions, [
            Subscription(300, 310)
            ])

        XCTAssertEqual(results.events, [
            .next(260, 102),
            ])
    }
    
    func testConcatMap_OuterComplete_InnerNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
        ])
        
        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203)
        ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(50, 302),
            .completed(60)
        ])
        
        let ys4 = scheduler.createColdObservable([
            .completed(40, Int.self)
        ])
        
        let ys5 = scheduler.createColdObservable([
            .next(80, 401),
            .next(90, 402),
            .completed(100)
        ])
        
        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(550, ys3),
            .next(750, ys4),
            .next(850, ys5),
            .completed(900)
        ])
        
        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
        ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(760, 1000)
        ])
        
        XCTAssertEqual(ys3.subscriptions, [])
        
        XCTAssertEqual(ys4.subscriptions, [])
        
        XCTAssertEqual(ys5.subscriptions, [])
        
        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(940, 202),
            .next(950, 203)
        ])
    }
    
    func testConcatMap_InnerComplete_OuterNotComplete() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(205)
            ])
        
        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            ])
        
        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 1000)
        ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
        ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(760, 965)
        ])
        
        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(940, 202),
            .next(950, 203),
        ])
    }

    func testConcatMap_InnerComplete_OuterCompleteBeforeInner() {
        let scheduler = TestScheduler(initialClock: 0)

        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
            ])

        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(195)
            ])

        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .completed(405)
            ])

        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 405)
            ])

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(ys2.subscriptions, [
            Subscription(760, 955)
            ])

        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(940, 202),
            .next(950, 203),
            .completed(955)
            ])
    }

    func testConcatMap_InnerComplete_OuterCompleteAfterInner() {
        let scheduler = TestScheduler(initialClock: 0)

        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
            ])

        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(195)
            ])

        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .completed(980)
            ])

        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }

        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 980)
            ])

        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
            ])

        XCTAssertEqual(ys2.subscriptions, [
            Subscription(760, 955)
            ])

        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .next(940, 202),
            .next(950, 203),
            .completed(980)
            ])
    }
    
    func testConcatMap_Error_Outer() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
        ])
        
        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(205)
        ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(50, 302),
            .completed(60)
        ])
        
        let ys4 = scheduler.createColdObservable([
            .completed(40, Int.self)
        ])
        
        let ys5 = scheduler.createColdObservable([
            .next(80, 401),
            .next(90, 402),
            .completed(100)
        ])
        
        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(550, ys3),
            .next(750, ys4),
            .next(850, ys5),
            .error(900, testError)
        ])
        
        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 900)
        ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
        ])
        
        XCTAssertEqual(ys2.subscriptions, [
            Subscription(760, 900)
        ])
        XCTAssertEqual(ys3.subscriptions, [])
        XCTAssertEqual(ys4.subscriptions, [])
        XCTAssertEqual(ys5.subscriptions, [])
        
        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .error(900, testError)
        ])
    }
    
    func testConcatMap_Error_Inner() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .error(460, testError)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(205)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(50, 302),
            .completed(60)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .completed(40, Int.self)
            ])
        
        let ys5 = scheduler.createColdObservable([
            .next(80, 401),
            .next(90, 402),
            .completed(100)
            ])
        
        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(550, ys3),
            .next(750, ys4),
            .next(850, ys5),
            .error(900, testError)
            ])
        
        let results = scheduler.start {
            return xs.concatMap {
                return $0
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 760)
        ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 760)
        ])
        
        XCTAssertEqual(ys2.subscriptions, [])
        XCTAssertEqual(ys3.subscriptions, [])
        XCTAssertEqual(ys4.subscriptions, [])
        XCTAssertEqual(ys5.subscriptions, [])
        
        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .next(740, 106),
            .error(760, testError)
        ])
    }
    
    func testConcatMap_Throw() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            .next(10, 102),
            .next(90, 103),
            .next(110, 104),
            .next(190, 105),
            .next(440, 106),
            .completed(460)
            ])
        
        let ys2 = scheduler.createColdObservable([
            .next(180, 202),
            .next(190, 203),
            .completed(205)
            ])
        
        let ys3 = scheduler.createColdObservable([
            .next(10, 301),
            .next(50, 302),
            .completed(60)
            ])
        
        let ys4 = scheduler.createColdObservable([
            .completed(40, Int.self)
            ])
        
        let ys5 = scheduler.createColdObservable([
            .next(80, 401),
            .next(90, 402),
            .completed(100)
            ])
        
        let xs = scheduler.createHotObservable([
            .next(300, ys1),
            .next(400, ys2),
            .next(550, ys3),
            .next(750, ys4),
            .next(850, ys5),
            .completed(900)
            ])
        
        var invoked = 0
        
        let results = scheduler.start {
            return xs.concatMap { x -> TestableObservable<Int> in
                invoked += 1
                if invoked == 3 {
                    throw testError
                }
                return x
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 550)
            ])
        
        XCTAssertEqual(ys1.subscriptions, [
            Subscription(300, 550)
        ])
        
        XCTAssertEqual(ys2.subscriptions, [])
        XCTAssertEqual(ys3.subscriptions, [])
        XCTAssertEqual(ys4.subscriptions, [])
        XCTAssertEqual(ys5.subscriptions, [])
        
        XCTAssertEqual(results.events, [
            .next(310, 102),
            .next(390, 103),
            .next(410, 104),
            .next(490, 105),
            .error(550, testError)
        ])
    }
    
    func testConcatMap_UseFunction() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(210, 4),
            .next(220, 3),
            .next(250, 5),
            .next(270, 1),
            .completed(290)
        ])
        
        let results = scheduler.start {
            return xs.concatMap { x in
                return Observable<Int>.interval(.seconds(10), scheduler: scheduler)
                    .map { _ in
                        return x
                    }
                    .take(x)
            }
        }
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 290)
        ])
        
        XCTAssertEqual(results.events, [
            .next(220, 4),
            .next(230, 4),
            .next(240, 4),
            .next(250, 4),
            .next(260, 3),
            .next(270, 3),
            .next(280, 3),
            .next(290, 5),
            .next(300, 5),
            .next(310, 5),
            .next(320, 5),
            .next(330, 5),
            .next(340, 1),
            .completed(340)
        ])
    }

    #if TRACE_RESOURCES
        func testConcatMapReleasesResourcesOnComplete() {
            _ = Observable<Int>.just(1).concatMap { _ in Observable.just(1) }.subscribe()
        }

        func testConcatMapReleasesResourcesOnError1() {
            _ = Observable<Int>.error(testError).concatMap { _ in Observable.just(1) }.subscribe()
        }

        func testConcatMapReleasesResourcesOnError2() {
            _ = Observable<Int>.just(1).concatMap { _ -> Observable<Int> in throw testError }.subscribe()
        }

        func testConcatMapReleasesResourcesOnError3() {
            _ = Observable<Int>.just(1).concatMap { _ -> Observable<Int> in Observable.error(testError) }.subscribe()
        }
    #endif
}
