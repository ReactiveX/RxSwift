//
//  Observable+MultipleTest2.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/19/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

// MARK: merge
extension ObservableMultipleTest {
    func testMerge_DeadlockSimple() {
        var nEvents = 0
        
        let observable = Observable.of(
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2),
            Observable.of(0, 1, 2)
        ).merge()
        
        _ = observable.subscribe(onNext: { n in
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
        
        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge()

        _ = observable.subscribe(onError: { n in
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
        _ = observable.subscribe(onCompleted: { n in
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
        
        _ = observable.subscribe(onNext: { n in
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
    
    func testMergeConcurrent_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable: Observable<Observable<Int>> = Observable.just(
            Observable.error(testError)
        ).merge(maxConcurrent: 1)

        _ = observable.subscribe(onError: { n in
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

        _ = observable.subscribe(onCompleted: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testMerge_ObservableOfObservable_Data() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let ys1 = scheduler.createColdObservable([
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            next(120, 305),
            completed(150)
        ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
        ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            next(510, 105),
            next(510, 301),
            next(520, 106),
            next(520, 302),
            next(530, 303),
            next(540, 304),
            next(620, 305),
            completed(650)
        ]

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
            next(10, 101),
            next(20, 102),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(50)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 201),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            next(510, 301),
            next(520, 302),
            next(530, 303),
            next(540, 304),
            completed(600)
        ]

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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            error(50, testError1)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 301),
            next(20, 302),
            next(30, 303),
            next(40, 304),
            completed(150)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            next(500, ys3),
            completed(600)
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(450, testError1)
        ]

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
            next(10, 101),
            next(20, 102),
            next(110, 103),
            next(120, 104),
            next(210, 105),
            next(220, 106),
            completed(230)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(10, 201),
            next(20, 202),
            next(30, 203),
            next(40, 204),
            completed(50)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(300, ys1),
            next(400, ys2),
            error(500, testError1),
            ])
        
        let res = scheduler.start {
            xs.merge()
        }
        
        let messages = [
            next(310, 101),
            next(320, 102),
            next(410, 103),
            next(410, 201),
            next(420, 104),
            next(420, 202),
            next(430, 203),
            next(440, 204),
            error(500, testError1)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            next(670, 9),
            next(700, 10),
            completed(760)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            next(690, 9),
            next(720, 10),
            completed(780)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(450)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(280, 6),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 7),
            next(380, 8),
            next(630, 9),
            next(660, 10),
            completed(720)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(300)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(420, ys4),
            completed(750)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 3)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(280, 6),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 7),
            next(380, 8),
            next(630, 9),
            next(660, 10),
            completed(750)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start(450) {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            completed(130)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            error(400, testError1)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            error(400, testError1)
        ]

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
            next(50, 1),
            next(100, 2),
            next(120, 3),
            completed(140)
            ])
        
        let ys2 = scheduler.createColdObservable([
            next(20, 4),
            next(70, 5),
            completed(200)
            ])
        
        let ys3 = scheduler.createColdObservable([
            next(10, 6),
            next(90, 7),
            next(110, 8),
            error(140, testError1)
            ])
        
        let ys4 = scheduler.createColdObservable([
            next(210, 9),
            next(240, 10),
            completed(300)
            ])
        
        let xs: TestableObservable<TestableObservable<Int>> = scheduler.createHotObservable([
            next(210, ys1),
            next(260, ys2),
            next(270, ys3),
            next(320, ys4),
            completed(400)
            ])
        
        let res = scheduler.start {
            xs.merge(maxConcurrent: 2)
        }
        
        let messages = [
            next(260, 1),
            next(280, 4),
            next(310, 2),
            next(330, 3),
            next(330, 5),
            next(360, 6),
            next(440, 7),
            next(460, 8),
            error(490, testError1)
        ]

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
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1).delay(10, scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1))
                .concat(Observable<Int>.timer(20, scheduler: scheduler).flatMapLatest { _ in return Observable<Observable<Int>>.empty() })
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.never().timeout(10, scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }

        func testMerge2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Observable<Int>>.of(Observable.just(1), Observable.just(1))
                .concat(Observable.never().timeout(20, scheduler: scheduler))
                .merge()
                .subscribe()
            scheduler.start()
        }
    #endif
}

extension ObservableMultipleTest {
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
                completed(200, Int.self)
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
                next(10, 101),
                next(20, 102),
                completed(230)
                ])

            let ys2 = scheduler.createColdObservable([
                next(10, 201),
                next(20, 202),
                completed(50)
                ])

            let ys3 = scheduler.createColdObservable([
                next(10, 301),
                next(20, 302),
                completed(150)
                ])

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable(), ys3.asObservable())
            }

            let messages = [
                next(210, 101),
                next(210, 201),
                next(210, 301),
                next(220, 102),
                next(220, 202),
                next(220, 302),
                completed(430)
            ]

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
                next(10, 101),
                next(20, 102),
                completed(230)
                ])

            let ys2 = scheduler.createColdObservable([
                next(10, 201),
                error(15, testError)
                ])

            let ys3 = scheduler.createColdObservable([
                next(10, 301),
                next(20, 302),
                completed(150)
                ])

            let res = scheduler.start {
                factory(ys1.asObservable(), ys2.asObservable(), ys3.asObservable())
            }

            let messages = [
                next(210, 101),
                next(210, 201),
                next(210, 301),
                error(215, testError)
            ]

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

// MARK: combine latest
extension ObservableMultipleTest {

    func testCombineLatest_DeadlockErrorAfterN() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            Observable.concat([Observable.of(0, 1, 2), Observable.error(testError)]),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testCombineLatest_DeadlockErrorImmediatelly() {
        var nEvents = 0
        
        let observable = Observable.combineLatest(
            Observable.error(testError),
            Observable.of(0, 1, 2)
        ) { $0 + $1 }

        _ = observable.subscribe(onError: { n in
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }
    
    func testReplay_DeadlockEmpty() {
        var nEvents = 0
        
        
        let observable = Observable.combineLatest(
            Observable.empty(),
            Observable.of(0, 1, 2)
            ) { $0 + $1 }

        _ = observable.subscribe(onCompleted: {
            nEvents += 1
        })
        
        XCTAssertEqual(nEvents, 1)
    }

    #if TRACE_RESOURCES
        func testCombineLatestReleasesResourcesOnComplete() {
            _ = Observable.combineLatest(Observable.just(1), Observable.just(1), resultSelector: +).subscribe()
        }

        func testCombineLatestReleasesResourcesOnError() {
            _ = Observable.combineLatest(Observable.just(1), Observable<Int>.error(testError), resultSelector: +).subscribe()
        }
    #endif
}

// MARK: takeUntil
extension ObservableMultipleTest {
    func testTakeUntil_Preempt_SomeData_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 99),
            completed(230)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
    
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            completed(225)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
        ])

        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
        ])
    }
    
    func testTakeUntil_Preempt_SomeData_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }

        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            error(225, testError)
        ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
        ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_SomeData_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 250)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 250)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Next() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(225, 2),
            completed(250)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(225)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_Preempt_Never_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 225)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }

    func testTakeUntil_NoPreempt_Never_Empty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            completed(225)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 225)
            ])
    }
    
    func testTakeUntil_NoPreempt_Never_Never() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 1000)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 1000)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertEqual(l.subscriptions, [
            Subscription(200, 210)
            ])
        
        XCTAssertEqual(r.subscriptions, [
            Subscription(200, 210)
            ])
    }
    
    func testTakeUntil_Preempt_BeforeFirstProduced_RemainSilentAndProperDisposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(215, testError),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            completed(220)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.do(onNext: { _ in sourceNotDisposed = true }).takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            completed(210)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_NoPreempt_AfterLastProduced_ProperDisposedSigna() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            next(230, 2),
            completed(240)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(250, 2),
            completed(260)
            ])
        
        var sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r.do(onNext: { _ in sourceNotDisposed = true }))
        }
        
        XCTAssertEqual(res.events, [
            next(230, 2),
            completed(240)
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }
    
    func testTakeUntil_Error_Some() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let l = scheduler.createHotObservable([
            next(150, 1),
            error(225, testError)
            ])
        
        let r = scheduler.createHotObservable([
            next(150, 1),
            next(240, 2),
            ])
        
        let sourceNotDisposed = false
        
        let res = scheduler.start {
            l.takeUntil(r)
        }
        
        XCTAssertEqual(res.events, [
            error(225, testError),
            ])
        
        XCTAssertFalse(sourceNotDisposed)
    }

    #if TRACE_RESOURCES
        func testTakeUntil1ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).delay(10, scheduler: scheduler).takeUntil(Observable.just(1)).subscribe()
            scheduler.start()
        }

        func testTakeUntil2ReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable.just(1).takeUntil(Observable.just(1).delay(10, scheduler: scheduler)).subscribe()
            scheduler.start()
        }

        func testTakeUntil1ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().timeout(20, scheduler: scheduler).takeUntil(Observable<Int>.never()).subscribe()
            scheduler.start()
        }

        func testTakeUntil2ReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.never().takeUntil(Observable<Int>.never().timeout(20, scheduler: scheduler)).subscribe()
            scheduler.start()
        }
    #endif
}
