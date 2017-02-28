//
//  AnyVariableTest.swift
//  Tests
//
//  Created by Yasuhiro Inami on 2/28/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift

class AnyVariableTest : RxTest {
    func testAnyVariable_initialValues() {
        let a = AnyVariable(1)
        let b = AnyVariable(2)

        let c = Observable.combineLatest(a.asObservable(), b.asObservable(), resultSelector: +)

        var latestValue: Int?

        _ = c.subscribe(onNext: { next in
            latestValue = next
        })

        XCTAssertEqual(latestValue!, 3)
    }

    func testAnyVariable_sendsCompletedOnDealloc() {
        var a = AnyVariable(1)

        var latest = 0
        var completed = false
        _ = a.asObservable().subscribe(onNext: { n in
            latest = n
        }, onCompleted: {
            completed = true
        })

        XCTAssertEqual(latest, 1)
        XCTAssertFalse(completed)

        a = AnyVariable(2)

        XCTAssertEqual(latest, 1)
        XCTAssertTrue(completed)
    }

    func testAnyVariable_READMEExample() {

        // Two simple Rx variables
        // Every variable is actually a sequence future values in disguise.
        let a /*: Observable<Int>*/ = AnyVariable(1)
        let b /*: Observable<Int>*/ = AnyVariable(2)

        // Computed third variable (or sequence)
        let c /*: Observable<Int>*/ = Observable.combineLatest(a.asObservable(), b.asObservable()) { $0 + $1 }

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
            .subscribe(onNext: { c in
                //print("Next value of c = \(c)")
                latestValueOfC = c
            })

        defer {
            d.dispose()
        }

        XCTAssertEqual(latestValueOfC!, 3)

    }

}

