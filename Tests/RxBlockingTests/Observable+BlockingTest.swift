//
//  Observable+BlockingTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxBlocking
import XCTest

class ObservableBlockingTest : RxTest {
}

// toArray

extension ObservableBlockingTest {
    func testToArray_empty() {
        XCTAssertEqual(try Observable<Int>.empty().toBlocking().toArray(), [])
    }
    
    func testToArray_return() {
        XCTAssertEqual(try Observable.just(42).toBlocking().toArray(), [42])
    }
    
    func testToArray_fail() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.error(testError).toBlocking().toArray(), testError)
    }
    
    func testToArray_someData() {
        XCTAssertEqual(try Observable.of(42, 43, 44, 45).toBlocking().toArray(), [42, 43, 44, 45])
    }
    
    func testToArray_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let array = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .toArray()
        
        XCTAssertEqual(array, Array(0..<10))
    }

    func testToArray_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

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

    func testToArray_timeout() {
        XCTAssertThrowsError(try Observable<Int>.never().toBlocking(timeout: 0.01).toArray()) { error in
            XCTAssertErrorEqual(error, RxError.timeout)
        }
    }
}

// first

extension ObservableBlockingTest {
    func testFirst_empty() {
        XCTAssertNil(try Observable<Int>.empty().toBlocking().first())
    }
    
    func testFirst_return() {
        XCTAssertEqual(try Observable.just(42).toBlocking().first(), 42)
    }
    
    func testFirst_fail() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.error(testError).toBlocking().first(), testError)
    }
    
    func testFirst_someData() {
        XCTAssertEqual(try Observable.of(42, 43, 44, 45).toBlocking().first(), 42)
    }
    
    func testFirst_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let element = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .first()
        
        XCTAssertEqual(element, 0)
    }

    func testFirst_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

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

    func testFirst_timeout() {
        XCTAssertThrowsError(try Observable<Int>.never().toBlocking(timeout: 0.01).first()) { error in
            XCTAssertErrorEqual(error, RxError.timeout)
        }
    }
}

// last

extension ObservableBlockingTest {
    func testLast_empty() {
        XCTAssertNil(try Observable<Int>.empty().toBlocking().last())
    }
    
    func testLast_return() {
        XCTAssertEqual(try Observable.just(42).toBlocking().last(), 42)
    }
    
    func testLast_fail() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.error(testError).toBlocking().last(), testError)
    }
    
    func testLast_someData() {
        XCTAssertEqual(try Observable.of(42, 43, 44, 45).toBlocking().last(), 45)
    }
    
    func testLast_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let element = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(10)
            .toBlocking()
            .last()
        
        XCTAssertEqual(element, 9)
    }

    func testLast_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

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

    func testLast_timeout() {
        XCTAssertThrowsError(try Observable<Int>.never().toBlocking(timeout: 0.01).last()) { error in
            XCTAssertErrorEqual(error, RxError.timeout)
        }
    }
}


// single

extension ObservableBlockingTest {
    func testSingle_empty() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.empty().toBlocking().single(), RxError.noElements)
    }
    
    func testSingle_return() {
        XCTAssertEqual(try Observable.just(42).toBlocking().single(), 42)
    }

    func testSingle_two() {
        XCTAssertThrowsErrorEqual(try Observable.of(42, 43).toBlocking().single(), RxError.moreThanOneElement)
    }

    func testSingle_someData() {
        XCTAssertThrowsErrorEqual(try Observable.of(42, 43, 44, 45).toBlocking().single(), RxError.moreThanOneElement)
    }
    
    func testSingle_fail() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.error(testError).toBlocking().single(), testError)
    }
    
    func testSingle_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let element = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(1)
            .toBlocking()
            .single()
        
        XCTAssertEqual(element, 0)
    }

    
    func testSingle_predicate_empty() {
        XCTAssertThrowsErrorEqual(try Observable<Int>.empty().toBlocking().single { _ in true }, RxError.noElements)
    }
    
    func testSingle_predicate_return() {
        XCTAssertEqual(try Observable.just(42).toBlocking().single( { _ in true } ), 42)
    }
    
    func testSingle_predicate_someData_one_match() {
        var predicateVals = [Int]()
        do {
            let element = try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e == 44
            } )
            XCTAssertEqual(element, 44)
        }
        catch _ {
            XCTFail()
        }
        XCTAssertEqual(predicateVals, [42, 43, 44, 45])
    }

    func testSingle_predicate_someData_two_match() {
        var predicateVals = [Int]()
        do {
            _ = try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e >= 43
            } )
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, RxError.moreThanOneElement)
        }
        XCTAssertEqual(predicateVals, [42, 43, 44])
    }

    
    func testSingle_predicate_none() {
        var predicateVals = [Int]()
        do {
            _ = try Observable.of(42, 43, 44, 45).toBlocking().single( { e in
                predicateVals.append(e)
                return e > 50
            } )
            XCTFail()
        }
        catch let e {
            XCTAssertErrorEqual(e, RxError.noElements)
        }
        XCTAssertEqual(predicateVals, [42, 43, 44, 45])
    }

    func testSingle_predicate_throws() {
        var predicateVals = [Int]()
        do {
            _ = try Observable.of(42, 43, 44, 45, scheduler: CurrentThreadScheduler.instance).toBlocking().single( { e in
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
        XCTAssertThrowsErrorEqual(try Observable<Int>.error(testError).toBlocking().single { _ in true }, testError)
    }
    
    func testSingle_predicate_withRealScheduler() {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)
        
        let element = try! Observable<Int64>.interval(0.001, scheduler: scheduler)
            .take(4)
            .toBlocking()
            .single( { $0 == 3 } )
        
        XCTAssertEqual(element, 3)
    }

    func testSingle_independent() {
        for i in 0 ..< 10 {
            let scheduler = ConcurrentDispatchQueueScheduler(qos: .default)

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

    func testSingle_timeout() {
        XCTAssertThrowsError(try Observable<Int>.never().toBlocking(timeout: 0.01).single()) { error in
            XCTAssertErrorEqual(error, RxError.timeout)
        }
    }

    func testSinglePredicate_timeout() {
        XCTAssertThrowsError(try Observable<Int>.never().toBlocking(timeout: 0.01).single { _ in true }) { error in
            XCTAssertErrorEqual(error, RxError.timeout)
        }
    }
}

// materialize

extension ObservableBlockingTest {
    func testMaterialize_empty() {
        let result = Observable<Int>.empty().toBlocking().materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements, [])
        case .failed:
            XCTFail("Expected result to be complete successfully, but result was failed.")
        }
    }
    
    func testMaterialize_empty_fail() {
        let result = Observable<Int>.error(testError).toBlocking().materialize()
        
        switch result {
        case .completed:
            XCTFail("Expected result to be complete with error, but result was successful.")
        case .failed(let elements, let error):
            XCTAssertEqual(elements, [])
            XCTAssertErrorEqual(error, testError)
        }
    }
    
    func testMaterialize_someData() {
        let result = Observable.of(42, 43, 44, 45).toBlocking().materialize()
        
        switch result {
        case .completed(let elements):
            XCTAssertEqual(elements, [42, 43, 44, 45])
        case .failed:
            XCTFail("Expected result to be complete successfully, but result was failed.")
        }
    }
    
    func testMaterialize_someData_fail() {
        let sequence = Observable.concat(Observable.of(42, 43, 44, 45), Observable<Int>.error(testError))
        let result = sequence.toBlocking().materialize()
        
        switch result {
        case .completed:
            XCTFail("Expected result to be complete with error, but result was successful.")
        case .failed(let elements, let error):
            XCTAssertEqual(elements, [42, 43, 44, 45])
            XCTAssertErrorEqual(error, testError)
        }
    }
}
