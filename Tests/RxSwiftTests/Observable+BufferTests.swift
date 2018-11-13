//
//  Observable+BufferTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableBufferTest : RxTest {
}

extension ObservableBufferTest {
    func testBufferWithTimeOrCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(420, 8),
            .next(470, 9),
            .completed(600)
            ])
        
        
        let res = scheduler.start {
            xs.buffer(timeSpan: .seconds(70), count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            .next(240, EquatableArray([1, 2, 3])),
            .next(310, EquatableArray([4])),
            .next(370, EquatableArray([5, 6, 7])),
            .next(440, EquatableArray([8])),
            .next(510, EquatableArray([9])),
            .next(580, EquatableArray([])),
            .next(600, EquatableArray([])),
            .completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testBufferWithTimeOrCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(420, 8),
            .next(470, 9),
            .error(600, testError)
            ])
        
        let res = scheduler.start {
            xs.buffer(timeSpan: .seconds(70), count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            .next(240, EquatableArray([1, 2, 3])),
            .next(310, EquatableArray([4])),
            .next(370, EquatableArray([5, 6, 7])),
            .next(440, EquatableArray([8])),
            .next(510, EquatableArray([9])),
            .next(580, EquatableArray([])),
            .error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testBufferWithTimeOrCount_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(280, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(420, 8),
            .next(470, 9),
            .completed(600)
            ])
        
        let res = scheduler.start(disposed: 370) {
            xs.buffer(timeSpan: .seconds(70), count: 3, scheduler: scheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            .next(240, EquatableArray([1, 2, 3])),
            .next(310, EquatableArray([4])),
            .next(370, EquatableArray([5, 6, 7]))
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }

    func testBufferWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
        
        let result = try! Observable.range(start: 1, count: 10, scheduler: backgroundScheduler)
            .buffer(timeSpan: .seconds(1000), count: 3, scheduler: backgroundScheduler)
            .skip(1)
            .toBlocking()
            .first()
            
        XCTAssertEqual(result!, [4, 5, 6])
    }

    #if TRACE_RESOURCES
        func testBufferReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).buffer(timeSpan: .seconds(0), count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testBufferReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).buffer(timeSpan: .seconds(0), count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
    
    func testBufferWithBoundary_Default() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let hot = testScheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(255, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(875, 8),
            .next(900, 9),
            .next(999, 10),
            .completed(1000)
            ]).share()
        
        let debounced = hot.debounce(30, scheduler: testScheduler)

        let res = testScheduler.start(disposed: 1000) {
            hot.buffer(boundary: debounced).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            .next(285, EquatableArray([1, 2, 3, 4])),
            .next(400, EquatableArray([5, 6, 7])),
            .next(930, EquatableArray([8, 9])),
            .next(1000, EquatableArray([10])),
            .completed(1000)
            ])
    }
    
    func testBufferWithDebounce_Default() {
        let testScheduler = TestScheduler(initialClock: 0)
        
        let hot = testScheduler.createHotObservable([
            .next(205, 1),
            .next(210, 2),
            .next(240, 3),
            .next(255, 4),
            .next(320, 5),
            .next(350, 6),
            .next(370, 7),
            .next(875, 8),
            .next(900, 9),
            .next(999, 10),
            .completed(1000)
            ]
        )
        
        let res = testScheduler.start(disposed: 1000) {
            hot.buffer(debounce: 30, scheduler: testScheduler).map { EquatableArray($0) }
        }
        
        XCTAssertEqual(res.events, [
            .next(285, EquatableArray([1, 2, 3, 4])),
            .next(400, EquatableArray([5, 6, 7])),
            .next(930, EquatableArray([8, 9])),
            .next(1000, EquatableArray([10])),
            .completed(1000)
            ]
        )
    }
}
