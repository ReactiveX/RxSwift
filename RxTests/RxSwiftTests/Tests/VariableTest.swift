//
//  VariableTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 5/2/15.
//
//

import Foundation
import XCTest
import RxSwift

class VariableTest : RxTest {
    func testVariable_initialValues() {
        let a = Variable(1)
        let b = Variable(2)
        
        let c = combineLatest(a, b, +)
        
        var latestValue: Int?
        
        let subscription = c >- subscribeNext { next in
            latestValue = next
        }
        
        XCTAssertEqual(latestValue!, 3)
        
        a << 5

        XCTAssertEqual(latestValue!, 7)
        
        b << 9

        XCTAssertEqual(latestValue!, 14)
        
        subscription.dispose()
        
        a << 10

        XCTAssertEqual(latestValue!, 14)
    }
    
    func testVariable_NoInitialValues() {
        let a: Variable<Int> = Variable()
        let b: Variable<Int> = Variable()
        
        let c = combineLatest(a, b, +)
        
        var latestValue: Int? = nil
        
        let subscription = c >- subscribeNext { next in
            latestValue = next
        }
        
        XCTAssertTrue(latestValue == nil)
        
        a << 5
        
        XCTAssertTrue(latestValue == nil)
        
        b << 9
        
        XCTAssertTrue(latestValue == 14)
        
        subscription.dispose()
        
        a << 10
        
        XCTAssertTrue(latestValue == 14)
    }
    
    func testVariable_Error() {
        let a = Variable(1)
        let b = Variable(2)
        
        let c = combineLatest(a, b, +)
        
        var latestValue: Int?
        
        let subscription = c >- subscribeNext { next in
            latestValue = next
        }
        
        XCTAssertEqual(latestValue!, 3)
        
        a << 5
        
        XCTAssertEqual(latestValue!, 7)
        
        b.on(.Error(testError))
        
        b << 9
        
        XCTAssertEqual(latestValue!, 7)
        
        subscription.dispose()
        
        a << 10
        
        XCTAssertEqual(latestValue!, 7)
    }
    
    func testVariable_Completed() {
        let a = Variable(1)
        let b = Variable(2)
        
        let c = combineLatest(a, b, +)
        
        var latestValue: Int?
        
        let subscription = c >- subscribeNext { next in
            latestValue = next
        }
        
        XCTAssertEqual(latestValue!, 3)
        
        a << 5
        
        XCTAssertEqual(latestValue!, 7)
        
        b.on(.Error(testError))
        
        b << 9
        
        XCTAssertEqual(latestValue!, 7)
        
        subscription.dispose()
        
        a << 10
        
        XCTAssertEqual(latestValue!, 7)
    }
    
}