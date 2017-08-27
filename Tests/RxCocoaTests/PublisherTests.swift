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

class PublishRelayTest: RxTest {}

extension PublishRelayTest {
    func testPublishRelaySharing() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let observer1 = scheduler.createObserver(Int.self)
        let observer2 = scheduler.createObserver(Int.self)
        let observer3 = scheduler.createObserver(Int.self)
        var disposable1: Disposable!
        var disposable2: Disposable!
        var disposable3: Disposable!
        
        let publisher = PublishRelay<Int>()
        scheduler.scheduleAt(100) { publisher.accept(0) }
        scheduler.scheduleAt(210) { publisher.accept(1) }
        scheduler.scheduleAt(225) { publisher.accept(2) }
        scheduler.scheduleAt(245) { publisher.accept(3) }
        scheduler.scheduleAt(265) { publisher.accept(4)  }
        
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

extension PublishRelayTest {
    func testPublisherAlwaysObservingOnMainThread() {
        
        let relay = PublishRelay<Void>()
        let mainThreadExpectation = expectation(description: "PublishRelay emits items on main thread")
        
        let d = relay.asObservable().subscribe(onNext: {
            XCTAssertTrue(DispatchQueue.isMain)
            mainThreadExpectation.fulfill()
        })
        
        doOnBackgroundQueue {
            relay.accept(())
        }
        
        waitForExpectations(timeout: 0.5, handler: nil)
        d.dispose()
    }
}
