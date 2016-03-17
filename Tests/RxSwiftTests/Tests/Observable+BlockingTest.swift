//
//  Observable+BlockingTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
        XCTAssert(try! Observable<Int>.empty().toBlocking().toArray() == [])
    }
    
    func testToArray_return() {
        XCTAssert(try! Observable.just(42).toBlocking().toArray() == [42])
    }
    
    func testToArray_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().toArray()
            XCTFail("It should fail")
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testToArray_someData() {
        XCTAssert(try! Observable.of(42, 43, 44, 45).toBlocking().toArray() == [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .toArray()
        
        XCTAssert(array == Array(0..<10))
    }

    func testToArray_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

            func operation1()->Observable<Int>{
                return Observable.of(1, 2).subscribeOn(scheduler)
            }

            let a = try! operation1().toBlocking().toArray()
            let b = try! operation1().toBlocking().toArray()
            let c = try! operation1().toBlocking().toArray()
            let d = try! operation1().toBlocking().toArray()

            XCTAssertEqual(a, [1, 2])
            XCTAssertEqual(b, [1, 2])
            XCTAssertEqual(c, [1, 2])
            XCTAssertEqual(d, [1, 2])
        }
    }
}

// first

extension ObservableBlockingTest {
    func testFirst_empty() {
        XCTAssert(try! Observable<Int>.empty().toBlocking().first() == nil)
    }
    
    func testFirst_return() {
        XCTAssert(try! Observable.just(42).toBlocking().first() == 42)
    }
    
    func testFirst_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().first()
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testFirst_someData() {
        XCTAssert(try! Observable.of(42, 43, 44, 45).toBlocking().first() == 42)
    }
    
    func testFirst_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .first()
        
        XCTAssert(array == 0)
    }

    func testFirst_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

            func operation1()->Observable<Int>{
                return Observable.just(1).subscribeOn(scheduler)
            }

            let a = try! operation1().toBlocking().first()
            let b = try! operation1().toBlocking().first()
            let c = try! operation1().toBlocking().first()
            let d = try! operation1().toBlocking().first()

            XCTAssertEqual(a, 1)
            XCTAssertEqual(b, 1)
            XCTAssertEqual(c, 1)
            XCTAssertEqual(d, 1)
        }
    }
}

// last

extension ObservableBlockingTest {
    func testLast_empty() {
        XCTAssert(try! Observable<Int>.empty().toBlocking().last() == nil)
    }
    
    func testLast_return() {
        XCTAssert(try! Observable.just(42).toBlocking().last() == 42)
    }
    
    func testLast_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().last()
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testLast_someData() {
        XCTAssert(try! Observable.of(42, 43, 44, 45).toBlocking().last() == 45)
    }
    
    func testLast_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .last()
        
        XCTAssert(array == 9)
    }

    func testLast_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Background)

            func operation1()->Observable<Int>{
                return Observable.just(1).subscribeOn(scheduler)
            }

            let a = try! operation1().toBlocking().last()
            let b = try! operation1().toBlocking().last()
            let c = try! operation1().toBlocking().last()
            let d = try! operation1().toBlocking().last()

            XCTAssertEqual(a, 1)
            XCTAssertEqual(b, 1)
            XCTAssertEqual(c, 1)
            XCTAssertEqual(d, 1)
        }
    }
}


// single

extension ObservableBlockingTest {
    func testSingle_empty() {
        do {
            try Observable<Int>.empty().toBlocking().single()
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.NoElements._code)
        }
    }
    
    func testSingle_return() {
        XCTAssert(try! Observable.just(42).toBlocking().single() == 42)
    }

    func testSingle_two() {
        do {
            try Observable.of(42, 43).toBlocking().single()
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.MoreThanOneElement._code)
        }
    }

    func testSingle_someData() {
        do {
            try Observable.of(42, 43, 44, 45).toBlocking().single()
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.MoreThanOneElement._code)
        }
    }
    
    func testSingle_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().single()
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testSingle_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(1)
            .toBlocking()
            .single()
        
        XCTAssert(array == 0)
    }

    
    func testSingle_predicate_empty() {
        do {
            try Observable<Int>.empty().toBlocking().single { _ in true }
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.NoElements._code)
        }
    }
    
    func testSingle_predicate_return() {
        XCTAssert(try! Observable.just(42).toBlocking().single( { _ in true } ) == 42)
    }
    
    func testSingle_predicate_someData_one_match() {
        var predicateVals = [Int]()
        do {
            try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e == 44
            } )
        }
        catch _ {
            XCTFail()
        }
        XCTAssertEqual(predicateVals, [42, 43, 44, 45])
    }

    func testSingle_predicate_someData_two_match() {
        var predicateVals = [Int]()
        do {
            try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e >= 43
            } )
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.MoreThanOneElement._code)
        }
        XCTAssertEqual(predicateVals, [42, 43, 44])
    }

    
    func testSingle_predicate_none() {
        var predicateVals = [Int]()
        do {
            try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e > 50
            } )
            XCTFail()
        }
        catch let e {
            XCTAssertTrue((e as! RxError)._code == RxError.NoElements._code)
        }
        XCTAssertEqual(predicateVals, [42, 43, 44, 45])
    }

    func testSingle_predicate_throws() {
        var predicateVals = [Int]()
        do {
            try Observable.of(42, 43, 44, 45, scheduler: CurrentThreadScheduler.instance).toBlocking().single( { e in
                predicateVals.append(e)
                if e < 43 { return false }
                throw testError
            } )
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
        XCTAssertEqual(predicateVals, [42, 43])
    }
    
    func testSingle_predicate_fail() {
        do {
            try Observable<Int>.error(testError).toBlocking().single( { _ in true } )
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, testError)
        }
    }
    
    func testSingle_predicate_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(4)
            .toBlocking()
            .single( { $0 == 3 } )
        
        XCTAssert(array == 3)
    }

    func testSingle_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(globalConcurrentQueueQOS: .Default)

            func operation1()->Observable<Int>{
                return Observable.just(1).subscribeOn(scheduler)
            }

            let a = try! operation1().toBlocking().single()
            let b = try! operation1().toBlocking().single()
            let c = try! operation1().toBlocking().single()
            let d = try! operation1().toBlocking().single()

            XCTAssertEqual(a, 1)
            XCTAssertEqual(b, 1)
            XCTAssertEqual(c, 1)
            XCTAssertEqual(d, 1)
        }
    }
}
