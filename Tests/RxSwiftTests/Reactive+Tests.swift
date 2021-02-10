//
//  Reactive+Tests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/16/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest

class ReactiveTests: RxTest {
}

protocol Objecting: ReactiveCompatible {
    var number: Int { get set }
}

final class MyObject: Objecting {
    public var number = 0
    fileprivate var something = "" // this emulates associated objects
}

struct MyStruct: ReactiveCompatible {
    public var number = 0
}

extension Reactive where Base: MyObject {
    var somethingPublic: String {
        get { base.something }
        set { base.something = newValue }
    }
}

extension Reactive where Base: Objecting {
    var numberPublic: Int { base.number }
}

extension Reactive where Base == MyStruct {
    var numberPublic: Int { base.number }
}

extension ReactiveTests {
    func testEnablesMutations() {
        var object = MyObject()
        object.rx.somethingPublic = "Aha"

        XCTAssertEqual(object.something, "Aha")
        XCTAssertEqual(object.rx.somethingPublic, "Aha")
    }
    
    func testReactiveStruct() {
        var strct = MyStruct()
        strct.number = 800
        XCTAssertEqual(strct.rx.numberPublic, 800)
    }
    
    func testReactiveProtocol() {
        let object = MyObject()
        XCTAssertEqual(object.number, object.rx.numberPublic)
        
        object.number = 1000
        XCTAssertEqual(object.rx.numberPublic, 1000)
    }
    
    func testDynamicLookup() {
        let object = MyObject()
        _ = Observable.just(10).bind(to: object.rx.number)
        XCTAssertEqual(object.number, 10)
    }
}
