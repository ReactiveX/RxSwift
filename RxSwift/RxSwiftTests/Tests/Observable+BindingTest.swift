//
//  Observable+BindingTest.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

class ObservableBindingTest : RxTest {
    
}

// simple replay one tests
extension ObservableBindingTest {
    func testReplayOne_SimpleCase() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(110, 7),
            next(220, 3),
            next(280, 4),
            next(290, 1),
            next(340, 8),
            next(360, 5),
            next(370, 6),
            next(390, 7),
            next(410, 13),
            next(430, 2),
            next(450, 9),
            next(520, 11),
            next(560, 20),
            error(600, testError)
            ])
        
        var ys: ConnectableObservableType<Int>! = nil
        var subscription: Disposable! = nil
        var connection: Disposable! = nil
        var res: MockObserver<Int> = scheduler.createObserver()
        
        scheduler.scheduleAt(Defaults.created) { ys = xs >- replay(3) }
        scheduler.scheduleAt(450, action: { subscription = *ys.subscribe(ObserverOf(res)) })
        scheduler.scheduleAt(Defaults.disposed) { subscription.dispose() }
        
        scheduler.scheduleAt(300) { connection = *ys.connect() }
        scheduler.scheduleAt(400) { connection.dispose() }
        
        scheduler.scheduleAt(500) { connection = *ys.connect() }
        scheduler.scheduleAt(800) { connection.dispose() }
        
        scheduler.start();
        
        XCTAssertEqual(res.messages, [
            next(451, 5),
            next(452, 6),
            next(453, 7),
            next(521, 11),
            next(561, 20),
            error(601, testError)
        ])
        
        XCTAssertEqual(xs.subscriptions, [
            Subscription(300, 400),
            Subscription(500, 600)
        ])
    }
}