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
        
        let c = combineLatest(a, b, resultSelector: +)
        
        var latestValue: Int?
        
        let subscription = c
            .subscribeNext { next in
                latestValue = next
            }
        
        XCTAssertEqual(latestValue!, 3)
        
        a.value = 5

        XCTAssertEqual(latestValue!, 7)
        
        b.value = 9

        XCTAssertEqual(latestValue!, 14)
        
        subscription.dispose()
        
        a.value = 10

        XCTAssertEqual(latestValue!, 14)
    }

    func testVariable_READMEExample() {
        
        // Two simple Rx variables
        // Every variable is actually a sequence future values in disguise.
        let a /*: Observable<Int>*/ = Variable(1)
        let b /*: Observable<Int>*/ = Variable(2)
        
        // Computed third variable (or sequence)
        let c /*: Observable<Int>*/ = combineLatest(a, b) { $0 + $1 }
        
        // Reading elements from c.
        // This is just a demo example.
        // Sequence elements are usually never enumerated like this.
        // Sequences are usually combined using map/filter/combineLatest ...
        //
        // This will immediatelly print:
        //      Next value of c = 3
        // because variables have initial values (starting element)
        var latestValueOfC : Int? = nil
        // let _ = doesn't retain.
        let d/*: Disposable*/  = c
            .subscribeNext { c in
                //print("Next value of c = \(c)")
                latestValueOfC = c
            }

        defer {
            d.dispose()
        }
        
        XCTAssertEqual(latestValueOfC!, 3)
        
        // This will print:
        //      Next value of c = 5
        a.value = 3
        
        XCTAssertEqual(latestValueOfC!, 5)
        
        // This will print:
        //      Next value of c = 8
        b.value = 5
        
        XCTAssertEqual(latestValueOfC!, 8)
    }
    
}

