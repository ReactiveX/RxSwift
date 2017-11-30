//
//  Observable+WindowTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/29/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableWindowTest : RxTest {
}

extension ObservableWindowTest {
    func testWindowWithTimeOrCount_Basic() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.enumerated().map { (i: Int, o: Observable<Int>) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7"),
            next(420, "3 8"),
            next(470, "4 9"),
            completed(600)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testWindowWithTimeOrCount_Error() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            error(600, testError)
            ])
        
        let res = scheduler.start { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.enumerated().map { (i: Int, o: Observable<Int>) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                    }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7"),
            next(420, "3 8"),
            next(470, "4 9"),
            error(600, testError)
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 600)
            ])
    }
    
    func testWindowWithTimeOrCount_Disposed() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(105, 0),
            next(205, 1),
            next(210, 2),
            next(240, 3),
            next(280, 4),
            next(320, 5),
            next(350, 6),
            next(370, 7),
            next(420, 8),
            next(470, 9),
            completed(600)
            ])
        
        let res = scheduler.start(disposed: 370) { () -> Observable<String> in
            let window: Observable<Observable<Int>> = xs.window(timeSpan: 70, count: 3, scheduler: scheduler)
            let mappedWithIndex = window.enumerated().map { (i: Int, o: Observable<Int>) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                }
            }
            let result = mappedWithIndex.merge()
            return result
        }
        
        XCTAssertEqual(res.events, [
            next(205, "0 1"),
            next(210, "0 2"),
            next(240, "0 3"),
            next(280, "1 4"),
            next(320, "2 5"),
            next(350, "2 6"),
            next(370, "2 7")
            ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(200, 370)
            ])
    }
    
    func windowWithTimeOrCount_Default() {
        let backgroundScheduler = SerialDispatchQueueScheduler(qos: .default)
        
        let result = try! Observable.range(start: 1, count: 10, scheduler: backgroundScheduler)
            .window(timeSpan: 1000, count: 3, scheduler: backgroundScheduler)
            .enumerated().map { (i: Int, o: Observable<Int>) -> Observable<String> in
                return o.map { (e: Int) -> String in
                    return "\(i) \(e)"
                    }
            }
            .merge()
            .skip(4)
            .toBlocking()
            .first()
    
        XCTAssertEqual(result!, "1 5")
    }

    #if TRACE_RESOURCES
        func testWindowReleasesResourcesOnComplete() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.just(1).window(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }

        func testWindowReleasesResourcesOnError() {
            let scheduler = TestScheduler(initialClock: 0)
            _ = Observable<Int>.error(testError).window(timeSpan: 0.0, count: 10, scheduler: scheduler).subscribe()
            scheduler.start()
        }
    #endif
}
