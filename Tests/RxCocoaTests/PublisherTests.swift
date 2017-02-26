//
//  PublisherTests.swift
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

class PublisherTest: RxTest {}

extension PublisherTest {
    func testPublisherSharing() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let observer1 = scheduler.createObserver(Int.self)
        let observer2 = scheduler.createObserver(Int.self)
        let observer3 = scheduler.createObserver(Int.self)
        var disposable1: Disposable!
        var disposable2: Disposable!
        var disposable3: Disposable!
        
        let publisher = Publisher<Int>()
        scheduler.scheduleAt(100) { publisher.publish(0) }
        scheduler.scheduleAt(210) { publisher.publish(1) }
        scheduler.scheduleAt(225) { publisher.publish(2) }
        scheduler.scheduleAt(245) { publisher.publish(3) }
        scheduler.scheduleAt(265) { publisher.publish(4)  }
        
        scheduler.scheduleAt(200) {
            disposable1 = publisher.asObservable().subscribe(observer1)
        }
        
        scheduler.scheduleAt(220) {
            disposable2 = publisher.asObservable().subscribe(observer2)
        }
        
        scheduler.scheduleAt(235) {
            disposable1.dispose()
        }
        
        scheduler.scheduleAt(260) {
            disposable2.dispose()
        }
        
        // resubscription
        
        scheduler.scheduleAt(260) {
            disposable3 = publisher.asObservable().subscribe(observer3)
        }
        
        scheduler.scheduleAt(285) {
            disposable3.dispose()
        }
        
        scheduler.start()
        
        XCTAssertEqual(observer1.events, [
            next(210, 1),
            next(225, 2)
            ])
        
        XCTAssertEqual(observer2.events, [
            next(225, 2),
            next(245, 3)
            ])
        
        XCTAssertEqual(observer3.events, [
            next(265, 4)
            ])
    }
}

extension PublisherTest {
    func testEventHubAlwaysObservingOnMainThread() {
        var observedOnMainQueue = false
        
        let expectSubscribeOffMainQueue = expectation(description: "Did subscribe off main thread")
        
        let publisher = Publisher<Int>()
        
        _ = publisher.asEventHub().asObservable().subscribe(onNext: { value in
            XCTAssertTrue(DispatchQueue.isMain)
            observedOnMainQueue = true
            XCTAssertEqual(value, 1)
        })
        
        doOnBackgroundQueue {
            let d = publisher.asObservable().subscribe { n in
                
            }
            let d2 = publisher.asObservable().subscribe { n in
                
            }
            doOnMainQueue {
                d.dispose()
                d2.dispose()
                expectSubscribeOffMainQueue.fulfill()
            }
        }
        
        publisher.publish(1)
        
        waitForExpectations(timeout: 1.0) { error in
            XCTAssertNil(error)
        }
        
        XCTAssertTrue(observedOnMainQueue)
    }
}

// MARK: map
extension PublisherTest {
    func testPublisherMap() {
        let publisher = Publisher<Int>()
        
        let observer = PrimitiveMockObserver<Int>()
        let _ = publisher.asEventHub().map { $0 + 1 }.asObservable().subscribe(observer)
        
        publisher.publish(0)
        
        XCTAssertEqual(observer.events, [next(1)])
    }
}

// MARK: combine with Driver Sequence
extension PublisherTest {
    func testEventHubIsDriverCombinable() {
        let publisher = Publisher<Void>()
        
        let driver = Driver.just(1)
        let exp = expectation(description: "With latest from driver")
        _ = publisher.asEventHub().map { $0 }.withLatestFrom(driver).asDriver(onErrorJustReturn: 0).drive(onNext: { value in
            XCTAssertEqual(value, 1)
            exp.fulfill()
        })
        
        publisher.publish()
        
        waitForExpectations(timeout: 0.3, handler: nil)
    }
}
