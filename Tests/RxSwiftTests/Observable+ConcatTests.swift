//
//  Observable+ConcatTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableConcatTest : RxTest {
}

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
func generateCollection<T>(_ startIndex: Int, _ generator: @escaping (Int) -> Observable<T>) -> Observable<T> {
    let all = [0, 1].lazy.map { i in
        return i == 0 ? generator(startIndex) : generateCollection(startIndex + 1, generator)
    }
    return Observable.concat(all)
}

// this generates
// [generator(0), [generator(1), [generator(2), ..].concat()].concat()].concat()
// This should
func generateSequence<T>(_ startIndex: Int, _ generator: @escaping (Int) -> Observable<T>) -> Observable<T> {
    let indexes: [Int] = [0, 1]
    let all = AnySequence(indexes.lazy.map { (i: Int) -> Observable<T> in
        return i == 0 ? generator(startIndex) : generateSequence(startIndex + 1, generator)
    })
    return Observable<T>.concat(all)
}

// MARK: concat
extension ObservableConcatTest {
    func testConcat_DefaultScheduler() {
        var sum = 0
        _ = Observable.concat([Observable.just(1), Observable.just(2), Observable.just(3)]).subscribe(onNext: { (e) -> Void in
            sum += e
        })
        
        XCTAssertEqual(sum, 6)
    }
    
    func testConcat_IEofIO() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createColdObservable([
            .next(10, 1),
            .next(20, 2),
            .next(30, 3),
            .completed(40),
        ])
        
        let xs2 = scheduler.createColdObservable([
            .next(10, 4),
            .next(20, 5),
            .completed(30),
        ])
        
        let xs3 = scheduler.createColdObservable([
            .next(10, 6),
            .next(20, 7),
            .next(30, 8),
            .next(40, 9),
            .completed(50)
        ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2, xs3].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(210, 1),
            .next(220, 2),
            .next(230, 3),
            .next(250, 4),
            .next(260, 5),
            .next(280, 6),
            .next(290, 7),
            .next(300, 8),
            .next(310, 9),
            .completed(320)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 240),
        ])

        XCTAssertEqual(xs2.subscriptions, [
            Subscription(240, 270),
        ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(270, 320),
        ])
    }
    
    func testConcat_EmptyEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.completed(250, Int.self)
        ]

        XCTAssertEqual(res.events, messages)

        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_EmptyNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 1000),
            ])
    }
    
    func testConcat_NeverNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 1000),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_EmptyThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.error(250, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])

        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ThrowEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .error(230, testError),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.error(230, testError, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ThrowThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .error(230, testError1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError2)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.error(230, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnEmpty() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(210, 2),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_EmptyReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(240, 2),
            .completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(240, 2),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ReturnNever() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(230),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.next(210, 2),
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 1000),
            ])
    }
    
    func testConcat_NeverReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .completed(230),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages: [Recorded<Event<Int>>] = [
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 1000),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(240, 3),
            .completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(220, 2),
            .next(240, 3),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_ThrowReturn() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .error(230, testError1)
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(240, 2),
            .completed(250),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = [
            Recorded.error(230, testError1, Int.self)
        ]

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            ])
    }
    
    func testConcat_ReturnThrow() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(220, 2),
            .completed(230)
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .error(250, testError2),
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(220, 2),
            .error(250, testError2)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 250),
            ])
    }
    
    func testConcat_SomeDataSomeData() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .completed(225)
            ])
        
        let xs2 = scheduler.createHotObservable([
            .next(150, 1),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(210, 2),
            .next(220, 3),
            .next(230, 4),
            .next(240, 5),
            .completed(250)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 225),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(225, 250),
            ])
    }
    
    func testConcat_EnumerableTiming() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs1 = scheduler.createHotObservable([
            .next(150, 1),
            .next(210, 2),
            .next(220, 3),
            .completed(230)
            ])
        
        let xs2 = scheduler.createColdObservable([
            .next(50, 4),
            .next(60, 5),
            .next(70, 6),
            .completed(80)
            ])
        
        let xs3 = scheduler.createHotObservable([
            .next(150, 1),
            .next(200, 2),
            .next(210, 3),
            .next(220, 4),
            .next(230, 5),
            .next(270, 6),
            .next(320, 7),
            .next(330, 8),
            .completed(340)
            ])
        
        let res = scheduler.start {
            Observable.concat([xs1, xs2, xs3, xs2].map { $0.asObservable() })
        }
        
        let messages = Recorded.events(
            .next(210, 2),
            .next(220, 3),
            .next(280, 4),
            .next(290, 5),
            .next(300, 6),
            .next(320, 7),
            .next(330, 8),
            .next(390, 4),
            .next(400, 5),
            .next(410, 6),
            .completed(420)
        )

        XCTAssertEqual(res.events, messages)
        
        XCTAssertEqual(xs1.subscriptions, [
            Subscription(200, 230),
            ])
        
        XCTAssertEqual(xs2.subscriptions, [
            Subscription(230, 310),
            Subscription(340, 420),
            ])
        
        XCTAssertEqual(xs3.subscriptions, [
            Subscription(310, 340),
            ])
        
    }

    func testConcat_variadicElementsOverload() {
        let elements = try! Observable.concat(Observable.just(1)).toBlocking().toArray()
        XCTAssertEqual(elements, [1])
    }

#if TRACE_RESOURCES
    func testConcat_TailRecursionCollection() {
        maxTailRecursiveSinkStackSize = 0
        let elements = try! generateCollection(0) { i in
                Observable.just(i, scheduler: CurrentThreadScheduler.instance)
            }
            .take(10000)
            .toBlocking()
            .toArray()

        XCTAssertEqual(elements, Array(0 ..< 10000))
        XCTAssertEqual(maxTailRecursiveSinkStackSize, 1)
    }

    func testConcat_TailRecursionSequence() {
        maxTailRecursiveSinkStackSize = 0
        let elements = try! generateSequence(0) { i in
                Observable.just(i, scheduler: CurrentThreadScheduler.instance)
            }
            .take(10000)
            .toBlocking()
            .toArray()

        XCTAssertEqual(elements, Array(0 ..< 10000))
        XCTAssertTrue(maxTailRecursiveSinkStackSize > 1000)
    }
#endif


    #if TRACE_RESOURCES
        func testConcatReleasesResourcesOnComplete() {
            _ = Observable.concat([Observable.just(1)]).subscribe()
        }

        func testConcatReleasesResourcesOnError() {
            _ = Observable.concat([Observable<Int>.error(testError)]).subscribe()
        }
    #endif
}


