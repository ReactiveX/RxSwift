//
//  Observable+CreationTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 9/2/15.
//
//

import Foundation
import XCTest
import RxSwift

class ObservableCreationTests : RxTest {
    
}

extension ObservableCreationTests {
    func testGenerate_Finite() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            generate(0, condition: { x in x <= 3 }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 0),
            next(202, 1),
            next(203, 2),
            next(204, 3),
            completed(205)
            ])
        
    }
    
    func testGenerate_ThrowCondition() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            generate(0, condition: { _ in throw testError }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
            error(201, testError)
            ])
        
    }
    
    func testGenerate_ThrowIterate() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            generate(0, condition: { _ in true }, scheduler: scheduler) { (_: Int) -> Int in
                throw testError
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 0),
            error(202, testError)
            ])
        
    }
    
    func testGenerate_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(203) {
            generate(0, condition: { _ in true }, scheduler: scheduler) { x in
                x + 1
            }
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 0),
            next(202, 1)
            ])
        
    }
    
    func testGenerate_take() {
        var count = 0
    
        var elements = [Int]()
        
        _ = generate(0, condition: { _ in true }) { x in
                count++
                return x + 1
            }
            .take(4)
            .subscribe(onNext: { x in
                elements.append(x)
            })
        
        XCTAssertEqual(elements, [0, 1, 2, 3])
        XCTAssertEqual(count, 3)
    }
}

// range
extension ObservableCreationTests {
    func testRange_Boundaries() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start {
            range(Int.max, 1, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(201, Int.max),
            completed(202)
            ])
    }
    
    func testRange_Dispose() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(204) {
            range(-10, 5, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(201, -10),
            next(202, -9),
            next(203, -8)
            ])
    }
}

// repeatElement
extension ObservableCreationTests {
    func testRepeat_Element() {
        let scheduler = TestScheduler(initialClock: 0)
        
        let res = scheduler.start(207) {
            repeatElement(42, scheduler)
        }
        
        XCTAssertEqual(res.messages, [
            next(201, 42),
            next(202, 42),
            next(203, 42),
            next(204, 42),
            next(205, 42),
            next(206, 42)
        ])
    }
}