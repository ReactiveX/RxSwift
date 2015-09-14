//
//  Observable+BlockingTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/12/15.
//
//

import Foundation
import RxSwift
import RxBlocking
import XCTest

class ObservableBlockingTest : RxTest {
    override func tearDown() {
        sleep(0.1)
        super.tearDown()
    }
}

// toArray

extension ObservableBlockingTest {
    func testToArray_empty() {
        XCTAssert(try! (empty() as Observable<Int>).toArray() == [])
    }
    
    func testToArray_return() {
        XCTAssert(try! just(42).toArray() == [42])
    }
    
    func testToArray_fail() {
        do {
            try (failWith(testError) as Observable<Int>).toArray()
            XCTFail("It should fail")
        }
        catch {
            
        }
    }
    
    func testToArray_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).toArray() == [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .toArray()
        
        XCTAssert(array == Array(0..<10))
    }
}

// first

extension ObservableBlockingTest {
    func testFirst_empty() {
        XCTAssert(try! (empty() as Observable<Int>).first() == nil)
    }
    
    func testFirst_return() {
        XCTAssert(try! just(42).first() == 42)
    }
    
    func testFirst_fail() {
        do {
            try (failWith(testError) as Observable<Int>).first()
            XCTFail()
        }
        catch {
            
        }
    }
    
    func testFirst_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).first() == 42)
    }
    
    func testFirst_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .first()
        
        XCTAssert(array == 0)
    }
}

// last

extension ObservableBlockingTest {
    func testLast_empty() {
        XCTAssert(try! (empty() as Observable<Int>).last() == nil)
    }
    
    func testLast_return() {
        XCTAssert(try! just(42).last() == 42)
    }
    
    func testLast_fail() {
        do {
            try (failWith(testError) as Observable<Int>).last()
            XCTFail()
        }
        catch {
            
        }
    }
    
    func testLast_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).last() == 45)
    }
    
    func testLast_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .last()
        
        XCTAssert(array == 9)
    }
}


