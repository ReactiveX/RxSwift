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
    let dynamicSublasses: Int
    let swizzledForwardClasses: Int
    let interceptedClasses: Int
    let methodsSwizzled: Int
    let methodsForwarded: Int

    static var noChange: RxObjCRuntimeChange {
        return RxObjCRuntimeChange(
            dynamicSublasses: 0,
            swizzledForwardClasses: 0,
            interceptedClasses: 0,
            methodsSwizzled: 0,
            methodsForwarded: 0
        )
    }

    static func generatedNewClassWith(swizzledMethods swizzledMethods: Int, forwardedMethods: Int, hasSwizzledForward: Bool) -> RxObjCRuntimeChange {
        return RxObjCRuntimeChange(
            dynamicSublasses: 1,
            swizzledForwardClasses: hasSwizzledForward ? 1 : 0,
            interceptedClasses: 1,
            methodsSwizzled: swizzledMethods + (hasSwizzledForward ? 3 : 0),
            methodsForwarded: forwardedMethods)
    }

    static func forwardedMethods(forwardedMethods: Int, swizzledForwardClasses: Int, interceptedClasses: Int) -> RxObjCRuntimeChange {
        return RxObjCRuntimeChange(
            dynamicSublasses: 0,
            swizzledForwardClasses: swizzledForwardClasses,
            interceptedClasses: interceptedClasses,
            methodsSwizzled: swizzledForwardClasses * 3,
            methodsForwarded: forwardedMethods
        )
    }

    static func swizzledMethod(methodsSwizzled: Int, interceptedClasses: Int) -> RxObjCRuntimeChange {
        return RxObjCRuntimeChange(
            dynamicSublasses: 0,
            swizzledForwardClasses: 0,
            interceptedClasses: interceptedClasses,
            methodsSwizzled: methodsSwizzled,
            methodsForwarded: 0
        )
    }
}

class RxObjCRuntimeState {
    // total number of dynamically genertated classes
    let dynamicSublasses: Int
    // total number of classes that have swizzled forwarding mechanism
    let swizzledForwardClasses: Int
    // total number of classes that have at least one selector intercepted by either forwarding or sending messages
    let interceptingClasses: Int
    // total numbers of methods that are swizzled, methods used for forwarding (forwardInvocation, respondsToSelector, methodSignatureForSelector, class) also count
    let methodsSwizzled: Int
    // total number of methods that are intercepted by forwarding
    let methodsForwarded: Int

    init() {
        #if DEBUG
        dynamicSublasses = RX_number_of_dynamic_subclasses()
        swizzledForwardClasses = RX_number_of_forwarding_enabled_classes()
        interceptingClasses = RX_number_of_intercepting_classes()
        methodsSwizzled = RX_number_of_swizzled_methods()
        methodsForwarded = RX_number_of_forwarded_methods()
        #else
        dynamicSublasses = 0
        swizzledForwardClasses = 0
        interceptingClasses = 0
        methodsSwizzled = 0
        methodsForwarded = 0
        #endif
    }

    func assertAfterThisMoment(previous: RxObjCRuntimeState, changed: RxObjCRuntimeChange) {
        XCTAssertEqual(dynamicSublasses - previous.dynamicSublasses, changed.dynamicSublasses)
        XCTAssertEqual(swizzledForwardClasses - previous.swizzledForwardClasses, changed.swizzledForwardClasses)
        XCTAssertEqual(interceptingClasses - previous.interceptingClasses, changed.interceptedClasses)
        XCTAssertEqual(methodsSwizzled - previous.methodsSwizzled, changed.methodsSwizzled)
        XCTAssertEqual(methodsForwarded - previous.methodsForwarded, changed.methodsForwarded)
    }
}