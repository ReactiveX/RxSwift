//
//  Observable+DistinctTests.swift
//  AllTests-iOS
//
//  Created by Siarhei Fedartsou on 11/22/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class Observable_DistinctTests: RxTest {
    
    func testDistinct_allChanges() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
            ])
        
        let res = scheduler.start { xs.distinct { $0 } }
        
        let correctMessages = [
            next(210, 2),
            next(220, 3),
            next(230, 4),
            next(240, 5),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinct_someChanges() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2), // *
            next(215, 3), // *
            next(220, 3),
            next(225, 2),
            next(230, 7), // *
            next(235, 5), // *
            next(240, 42), // *
            completed(250)
            ])
        
        
        let res = scheduler.start { xs.distinct { $0 } }
        
        let correctMessages = [
            next(210, 2),
            next(215, 3),
            next(230, 7),
            next(235, 5),
            next(240, 42),
            completed(250)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 250)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
    
    func testDistinct_keySelectorThrows() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let xs = scheduler.createHotObservable([
            next(150, 1),
            next(210, 2),
            next(220, 3),
            completed(250)
            ])
        
        var call = 0
        let res = scheduler.start {
            xs.distinct{ (_) -> Int in
                if call == 0 {
                    call += 1
                    return 42
                } else {
                    throw testError
                }
            }
        }
    
        let correctMessages = [
            next(210, 2),
            error(220, testError)
        ]
        
        let correctSubscriptions = [
            Subscription(200, 220)
        ]
        
        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }

    
}
