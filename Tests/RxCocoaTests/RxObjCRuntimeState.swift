//
//  RxObjCRuntimeState.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest

struct RxObjCRuntimeChange {
    let dynamicSublasses: Int
    let swizzledForwardClasses: Int
    let interceptedClasses: Int
    let methodsSwizzled: Int
    let methodsForwarded: Int

    /**
     Takes into account default methods that were swizzled while creating dynamic subclasses.
    */
    static func changes(dynamicSubclasses: Int = 0, swizzledForwardClasses: Int = 0, interceptedClasses: Int = 0, methodsSwizzled: Int = 0, methodsForwarded: Int = 0) -> RxObjCRuntimeChange {
        return RxObjCRuntimeChange(
            dynamicSublasses: dynamicSubclasses,
            swizzledForwardClasses: swizzledForwardClasses,
            interceptedClasses: dynamicSubclasses + interceptedClasses,
            methodsSwizzled: methodsSwizzled + 1/*class*/ * dynamicSubclasses + 3/*forwardInvocation, respondsToSelector, methodSignatureForSelector*/ * swizzledForwardClasses,
            methodsForwarded: methodsForwarded
        )
    }
}

final class RxObjCRuntimeState {
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
        #if TRACE_RESOURCES
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

    func assertAfterThisMoment(_ previous: RxObjCRuntimeState, changed: RxObjCRuntimeChange) {
        #if TRACE_RESOURCES
        let realChangeOfDynamicSubclasses = dynamicSublasses - previous.dynamicSublasses
        XCTAssertEqual(realChangeOfDynamicSubclasses, changed.dynamicSublasses)
        if (realChangeOfDynamicSubclasses != changed.dynamicSublasses) {
            print("dynamic subclasses: real = \(realChangeOfDynamicSubclasses) != expected = \(changed.dynamicSublasses)")
        }
        let realSwizzledForwardClasses = swizzledForwardClasses - previous.swizzledForwardClasses
        XCTAssertEqual(realSwizzledForwardClasses, changed.swizzledForwardClasses)
        if (realSwizzledForwardClasses != changed.swizzledForwardClasses) {
            print("forward classes: real = \(realSwizzledForwardClasses) != expected = \(changed.swizzledForwardClasses)")
        }
        let realInterceptingClasses = interceptingClasses - previous.interceptingClasses
        XCTAssertEqual(realInterceptingClasses, changed.interceptedClasses)
        if (realInterceptingClasses != changed.interceptedClasses) {
            print("intercepting classes: real = \(realInterceptingClasses) != expected = \(changed.interceptedClasses)")
        }
        let realMethodsSwizzled = methodsSwizzled - previous.methodsSwizzled
        XCTAssertEqual(realMethodsSwizzled, changed.methodsSwizzled)
        if (realMethodsSwizzled != changed.methodsSwizzled) {
            print("swizzled methods: real = \(realMethodsSwizzled) != expected = \(changed.methodsSwizzled)")
        }
        let realMethodsForwarded = methodsForwarded - previous.methodsForwarded
        XCTAssertEqual(realMethodsForwarded, changed.methodsForwarded)
        if (realMethodsForwarded != changed.methodsForwarded) {
            print("forwarded methods: real = \(realMethodsForwarded) != expected = \(changed.methodsForwarded)")
        }
        #endif
    }
}
