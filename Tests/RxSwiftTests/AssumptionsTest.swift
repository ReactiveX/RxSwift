//
//  AssumptionsTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift

var deallocated = false
var realTest: Anything? = nil

func clearRealTest() {
    realTest = nil
}

func returnSomething() -> Observable<AnyObject?> {
    return Observable.just(NSNull())
}

func returnSomething() -> Observable<Int?> {
    return Observable.just(3)
}

class AssumptionsTest : RxTest {
    func testAssumptionInCodeIsThatArraysAreStructs() {
        let a = ["a"]
        var b = a
        b += ["b"]
        
        XCTAssert(a == ["a"])
        XCTAssert(b == ["a", "b"])
    }
   
    // http://lists.apple.com/archives/objc-language/2011/Nov/msg00005.html
    // but you never know :)
    func testFunctionCallRetainsArguments() {
        
        // first check is dealloc method working
        
        var a: Anything? = Anything()
        _ = a
        XCTAssertFalse(deallocated)
        a = nil
        XCTAssertTrue(deallocated)
        
        // then check unsafe
        
        deallocated = false
        
        realTest = Anything()
        
        XCTAssertFalse(deallocated)
        
        realTest?.justCallIt {
            XCTAssertFalse(deallocated)
            realTest = nil
            XCTAssertFalse(deallocated)
        }
        XCTAssertTrue(deallocated)
    }
    
    func testFunctionReturnValueOverload() {
        _ = returnSomething()
            .subscribe(onNext: { (n: AnyObject?) in
                XCTAssertEqual(n as? NSNull, NSNull())
            })

        _ = returnSomething()
            .subscribe(onNext: { (n: Int?) in
                XCTAssertEqual(n!, 3)
             })
    }
    
    func testArrayMutation() {
        var a = [1, 2, 3, 4]
        
        let b = a
        
        var count = 0
        for _ in b {
            a.removeAll()
            count += 1
        }
        
        XCTAssertTrue(count == 4)
    }
    
    func testResourceLeaksDetectionIsTurnedOn() {
#if TRACE_RESOURCES
        let startResourceCount = Resources.total
    
        var observable: Observable<Int>! = Observable.just(1)

        XCTAssertTrue(observable != nil)
        XCTAssertEqual(Resources.total, startResourceCount + 1)
        
        observable = nil

        XCTAssertEqual(Resources.total, startResourceCount)
#elseif RELEASE

#else
        XCTAssert(false, "Can't run unit tests in without tracing")
#endif
    }
}



class Anything {
    var elements = [Int]()
    
    func justCallIt(_ action: () -> Void) {
        clearRealTest()
        action()
    }
    
    deinit {
        deallocated = true
    }
}
