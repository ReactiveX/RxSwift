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

final class MyObject {
    fileprivate var _something: String = "" // this emulates associated objects
}

extension MyObject: ReactiveCompatible {
    
}

extension Reactive where Base: MyObject {
    var somethingPublic: String {
        get {
            return base._something
        }
        set {
            base._something = newValue
        }
    }
}

extension ReactiveTests {
    func testEnablesMutations() {
        var object = MyObject()

        object.rx.somethingPublic = "Aha"

        XCTAssertEqual(object._something, "Aha")
        XCTAssertEqual(object.rx.somethingPublic, "Aha")
    }
}
