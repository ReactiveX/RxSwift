//
//  RxObjCRuntimeState.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 11/27/15.
//
//

import Foundation
import XCTest

struct RxObjCRuntimeChange {
    let generatedNewClasses: Int
    let swizzledForward: Int
    let swizzledNewClasses: Int
    let newMethodsSwizzled: Int

    static var noChange: RxObjCRuntimeChange {
        return RxObjCRuntimeChange(generatedNewClasses: 0, swizzledForward: 0, swizzledNewClasses: 0, newMethodsSwizzled: 0)
    }

    static func generatedNewClassWith(swizzledMethods swizzledMethods: Int, hasSwizzledForward: Bool) -> RxObjCRuntimeChange {
        return RxObjCRuntimeChange(generatedNewClasses: 1, swizzledForward: hasSwizzledForward ? 1 : 0, swizzledNewClasses: 1, newMethodsSwizzled: swizzledMethods)
    }
}

class RxObjCRuntimeState {
    let numberOfGeneratedClasses: Int
    let numberOfSwizzledForwarding: Int
    let numberOfSwizzledClasses: Int
    let numberOfSwizzledSelectors: Int

    init() {
        numberOfGeneratedClasses = RX_number_of_swizzled_classes()
        numberOfSwizzledForwarding = RX_number_of_forwarding_enabled_classes()
        numberOfSwizzledClasses = RX_number_of_swizzled_classes()
        numberOfSwizzledSelectors = RX_number_of_swizzled_methods()
    }

    func assertAfterThisMoment(previous: RxObjCRuntimeState, changed: RxObjCRuntimeChange) {
        XCTAssertEqual(numberOfGeneratedClasses - previous.numberOfGeneratedClasses, changed.generatedNewClasses)
        XCTAssertEqual(numberOfSwizzledForwarding - previous.numberOfSwizzledForwarding, changed.swizzledForward)
        XCTAssertEqual(numberOfSwizzledClasses - previous.numberOfSwizzledClasses, changed.swizzledNewClasses)
        XCTAssertEqual(numberOfSwizzledSelectors - previous.numberOfSwizzledSelectors, changed.newMethodsSwizzled)
    }
}