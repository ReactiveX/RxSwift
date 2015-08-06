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
        XCTAssert((empty() as Observable<Int> >- toArray).get() == [])
    }
    
    func testToArray_return() {
        XCTAssert((just(42) >- toArray).get() == [42])
    }
    
    func testToArray_fail() {
        XCTAssert((failWith(testError) as Observable<Int> >- toArray).isFailure)
    }
    
    func testToArray_someData() {
        XCTAssert((returnElements(42, 43, 44, 45) >- toArray).get() == [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = interval(0.001, scheduler)
            >- take(10)
            >- toArray
        
        XCTAssert(array.get() == Array(0..<10))
    }
}

// first

extension ObservableBlockingTest {
    func testFirst_empty() {
        XCTAssert((empty() as Observable<Int> >- first).get() == nil)
    }
    
    func testFirst_return() {
        XCTAssert((just(42) >- first).get() == 42)
    }
    
    func testFirst_fail() {
        XCTAssert((failWith(testError) as Observable<Int> >- first).isFailure)
    }
    
    func testFirst_someData() {
        XCTAssert((returnElements(42, 43, 44, 45) >- first).get() == 42)
    }
    
    func testFirst_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = interval(0.001, scheduler)
            >- take(10)
            >- first
        
        XCTAssert(array.get() == 0)
    }
}

// last

extension ObservableBlockingTest {
    func testLast_empty() {
        XCTAssert((empty() as Observable<Int> >- last).get() == nil)
    }
    
    func testLast_return() {
        XCTAssert((just(42) >- last).get() == 42)
    }
    
    func testLast_fail() {
        XCTAssert((failWith(testError) as Observable<Int> >- last).isFailure)
    }
    
    func testLast_someData() {
        XCTAssert((returnElements(42, 43, 44, 45) >- last).get() == 45)
    }
    
    func testLast_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueuePriority: .Default)
        
        let array = interval(0.001, scheduler)
            >- take(10)
            >- last
        
        XCTAssert(array.get() == 9)
    }
}


