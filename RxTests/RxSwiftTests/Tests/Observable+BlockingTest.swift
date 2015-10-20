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
}

// toArray

extension ObservableBlockingTest {
    func testToArray_empty() {
        XCTAssert(try! (empty() as Observable<Int>).toBlocking().toArray() == [])
    }
    
    func testToArray_return() {
        XCTAssert(try! just(42).toBlocking().toArray() == [42])
    }
    
    func testToArray_fail() {
        do {
            try (failWith(testError) as Observable<Int>).toBlocking().toArray()
            XCTFail("It should fail")
        }
        catch {
            
        }
    }
    
    func testToArray_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).toBlocking().toArray() == [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .toBlocking()
            .toArray()
        
        XCTAssert(array == Array(0..<10))
    }
}

// first

extension ObservableBlockingTest {
    func testFirst_empty() {
        XCTAssert(try! (empty() as Observable<Int>).toBlocking().first() == nil)
    }
    
    func testFirst_return() {
        XCTAssert(try! just(42).toBlocking().first() == 42)
    }
    
    func testFirst_fail() {
        do {
            try (failWith(testError) as Observable<Int>).toBlocking().first()
            XCTFail()
        }
        catch {
            
        }
    }
    
    func testFirst_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).toBlocking().first() == 42)
    }
    
    func testFirst_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .toBlocking()
            .first()
        
        XCTAssert(array == 0)
    }
}

// last

extension ObservableBlockingTest {
    func testLast_empty() {
        XCTAssert(try! (empty() as Observable<Int>).toBlocking().last() == nil)
    }
    
    func testLast_return() {
        XCTAssert(try! just(42).toBlocking().last() == 42)
    }
    
    func testLast_fail() {
        do {
            try (failWith(testError) as Observable<Int>).toBlocking().last()
            XCTFail()
        }
        catch {
            
        }
    }
    
    func testLast_someData() {
        XCTAssert(try! sequenceOf(42, 43, 44, 45).toBlocking().last() == 45)
    }
    
    func testLast_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = try! interval(0.001, scheduler)
            .take(10)
            .toBlocking()
            .last()
        
        XCTAssert(array == 9)
    }
}


