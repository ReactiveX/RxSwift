//
//  SentMessageTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 11/21/15.
//
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

/**
These things needs to be tested

* observing sent messages to class that is pretending to be something else + by forwarding (one method, all supported types)
* observing sent messages to class that is pretending to be something else + optimized version (all supported types)
* observing sent messages to class that is pretending to be something else + dealloc
* observing sent messages to class that is pretending to be something else + observe forwardInvocation, methodSignatureForSelector, respondsToSelector

* observing sent messages to class that is not pretending to be something else + by forwarding (one method, all supported types)
* observing sent messages to class that is not pretending to be something else + optimized version (all supported types)
* observing sent messages to class that is not pretending to be something else + dealloc
* observing sent messages to class that is not pretending to be something else + observe forwardInvocation, methodSignatureForSelector, respondsToSelector

* observing sent messages to class that is core foundation briged type + by forwarding
* observing sent messages to class that is core foundation briged type + optimized version
* observing sent messages to class that is core foundation briged type + dealloc

* observing sent messages to class whose base is observed by forwarding + by forwarding (one method, all supported types)

* observing sent messages to class whose base is observed by optimized + by optimized (one method, all supported types)

* observing sent messages to class that has observed by forwarding a method + subclassing no collision (all supported types)
* observing sent messages to class that has observed by optimized version + subclassing no collision (all supported types)
 
* should forward to original forwardInvocation, respondsToSelector, methodSignatureForSelector
 
* message sent fires before base class invoked

* should work when observe by forwarding on dynamic subclass > then KVO > then observe other messages (by using dynamic subclass)
* should work when observe by optimized version on dynamic subclass > then KVO > then observe other messages (by using dynamic subclass)
* should work when KVO > then observe by forwarding (on acting class) > then remove KVO > observing works > then observe something else generates dynamic subclass and uses it > KVO > still uses dynamic sublass

*/
class SentMessageTest : RxTest {
    var testClosure: () -> () = { }

    func dynamicClassName(baseClassName: String) -> String {
        return "_RX_namespace_" + baseClassName
    }
}

// MARK: Observing by forwarding doesn't interfere in the same level

extension SentMessageTest {

    func testActing_forwarding_first_dynamic() {
        // first forwarding with dynamic sublass
        experimentWith(
            createKVODynamicSubclassed(SentMessageTest_intercept_forwarding_dyn_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
                .ImplementationChangedToForwarding(forSelector: "justCalledToSayObject:"),
                .ImplementationAdded(forSelector: "respondsToSelector:"),
                .ImplementationAdded(forSelector: "methodSignatureForSelector:"),
                .ImplementationAdded(forSelector: "forwardInvocation:"),
                .ImplementationAdded(forSelector: "_RX_namespace_justCalledToSayObject:"),
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.forwardedMethods(1, swizzledForwardClasses: 1, interceptedClasses: 1)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // forwarding with normal class
        experimentWith(
            createNormalInstance(SentMessageTest_intercept_forwarding_dyn_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_intercept_forwarding_dyn_first", andImplementsTheseSelectors: ["class"])
            ],
            runtimeChange: RxObjCRuntimeChange.generatedNewClassWith(swizzledMethods: 1, forwardedMethods: 0, hasSwizzledForward: false)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then again with dynamic
        experimentWith(
            createKVODynamicSubclassed(SentMessageTest_intercept_forwarding_dyn_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.noChange
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then again with normal
        experimentWith(
            createNormalInstance(SentMessageTest_intercept_forwarding_dyn_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_intercept_forwarding_dyn_first", andImplementsTheseSelectors: ["class"])
            ],
            runtimeChange: RxObjCRuntimeChange.noChange
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }
    }

    func testActing_forwarding_first_normal() {
        // first forwarding with normal first
        experimentWith(
            createNormalInstance(SentMessageTest_intercept_forwarding_normal_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_intercept_forwarding_normal_first", andImplementsTheseSelectors: [
                    "class",
                    "respondsToSelector:",
                    "methodSignatureForSelector:",
                    "forwardInvocation:",
                    "justCalledToSayObject:",
                    "_RX_namespace_justCalledToSayObject:",
                ])
            ],
            runtimeChange: RxObjCRuntimeChange.generatedNewClassWith(swizzledMethods: 1, forwardedMethods: 1, hasSwizzledForward: true)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then dynamic
        experimentWith(
            createKVODynamicSubclassed(SentMessageTest_intercept_forwarding_normal_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
                .ImplementationChangedToForwarding(forSelector: "justCalledToSayObject:"),
                .ImplementationAdded(forSelector: "respondsToSelector:"),
                .ImplementationAdded(forSelector: "methodSignatureForSelector:"),
                .ImplementationAdded(forSelector: "forwardInvocation:"),
                .ImplementationAdded(forSelector: "_RX_namespace_justCalledToSayObject:")
            ],
            objectRealClassChange: [
            ],
            runtimeChange: RxObjCRuntimeChange.forwardedMethods(1, swizzledForwardClasses: 1, interceptedClasses: 1)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then normal again
        experimentWith(
            createNormalInstance(SentMessageTest_intercept_forwarding_normal_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_intercept_forwarding_normal_first", andImplementsTheseSelectors: [
                    "class",
                    "respondsToSelector:",
                    "methodSignatureForSelector:",
                    "forwardInvocation:",
                    "justCalledToSayObject:",
                    "_RX_namespace_justCalledToSayObject:",
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.noChange
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then dynamic again
        experimentWith(
            createKVODynamicSubclassed(SentMessageTest_intercept_forwarding_normal_first.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
            ],
            runtimeChange: RxObjCRuntimeChange.noChange
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }
    }


}

// MARK: Optimized versions

extension SentMessageTest {
    /**
     All optimized versions
     SWIZZLE_OBSERVE_METHOD(void)

     SWIZZLE_OBSERVE_METHOD(void, id)
     SWIZZLE_OBSERVE_METHOD(void, int)
     SWIZZLE_OBSERVE_METHOD(void, long)
     SWIZZLE_OBSERVE_METHOD(void, BOOL)
     SWIZZLE_OBSERVE_METHOD(void, SEL)
     SWIZZLE_OBSERVE_METHOD(void, rx_uint)
     SWIZZLE_OBSERVE_METHOD(void, rx_ulong)
     SWIZZLE_OBSERVE_METHOD(void, rx_block)

     SWIZZLE_OBSERVE_METHOD(void, id, id)
     SWIZZLE_OBSERVE_METHOD(void, id, int)
     SWIZZLE_OBSERVE_METHOD(void, id, long)
     SWIZZLE_OBSERVE_METHOD(void, id, BOOL)
     SWIZZLE_OBSERVE_METHOD(void, id, SEL)
     SWIZZLE_OBSERVE_METHOD(void, id, rx_uint)
     SWIZZLE_OBSERVE_METHOD(void, id, rx_ulong)
     SWIZZLE_OBSERVE_METHOD(void, id, rx_block)
     */

    func testBaseClass_subClass_dont_interact_for_optimized_version_void() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_void.self,
            SentMessageTest_optimized_void.self,
            "voidJustCalledToSayVoid") { target in
            target.voidJustCalledToSayVoid()
            return [[[]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id.self,
            SentMessageTest_optimized_id.self,
            "voidJustCalledToSayObject:") { target in
            let o = NSObject()
            target.voidJustCalledToSayObject(o)
            return [[[o]]]
        }
    }

    /*func testBaseClass_subClass_dont_interact_for_optimized_version_closure() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_closure.self,
            SentMessageTest_optimized_closure.self,
            "voidJustCalledToSayClosure:") { target in
            target.voidJustCalledToSayClosure(self.testClosure)
            return [[[RXObjCTestRuntime.castClosure(self.testClosure)]]]
        }
    }*/

    func testBaseClass_subClass_dont_interact_for_optimized_version_int() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_int.self,
            SentMessageTest_optimized_int.self,
            "voidJustCalledToSayInt:") { target in
            target.voidJustCalledToSayInt(3)
            return [[[NSNumber(integer: 3)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_long() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_long.self,
            SentMessageTest_optimized_long.self,
            "voidJustCalledToSayLong:") { target in
            target.voidJustCalledToSayLong(3)
            return [[[NSNumber(long: 3)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_BOOL() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_BOOL.self,
            SentMessageTest_optimized_BOOL.self,
            "voidJustCalledToSayBool:") { target in
            target.voidJustCalledToSayBool(true)
            return [[[NSNumber(bool: true)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id_id.self,
            SentMessageTest_optimized_id_id.self,
            "voidJustCalledToSayObject:object:") { target in
            let o = NSObject()
            let o1 = NSObject()
            target.voidJustCalledToSayObject(o, object: o1)
            return [[[o, o1]]]
        }
    }

    func _baseClass_subClass_dont_interact_for_optimized_version
    <
        BaseClass: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>,
        TargetClass: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>
    >(baseClass: BaseClass.Type, _ targetClass: TargetClass.Type, _ method: Selector, _ invoke: BaseClass -> [[MethodParameters]]) {
        // first force base class forwarding

        experimentWith(
            createKVODynamicSubclassed(),
            observeIt: { (target: BaseClass) in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: method),
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.swizzledMethod(1, interceptedClasses: 1),
            useIt: invoke)

        
        // now force forwarding mechanism for normal class
        experimentWith(
            createKVODynamicSubclassed(),
            observeIt: { target in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: method),
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.swizzledMethod(1, interceptedClasses: 1)) { (target: TargetClass) in
                return invoke(target as! BaseClass)
        }

        // first force base class forwarding
        experimentWith(
            createKVODynamicSubclassed(),
            observeIt: { target in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.noChange,
            useIt: invoke)

        // now force forwarding mechanism for normal class
        experimentWith(
            createKVODynamicSubclassed(),
            observeIt: { target in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.noChange) { (target: TargetClass) in
                return invoke(target as! BaseClass)
        }
    }
}

// MARK: Forwarding doesn't interfere between subclasses

extension SentMessageTest {
    func testBasicForwardingCase() {
        performTestFirstOnNormalClassAndThenOnClassThatsActing(SentMessageTest_forwarding_basic()) { target, isActing in
            var messages = [[AnyObject]]()

            let d = target.rx_sentMessage("message_allSupportedParameters:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:").subscribe(onNext: { n in
                    messages.append(n)
                }, onError: { e in
                    XCTFail("Errors out \(e)")
                })

            let objectParam = NSObject()
            let str: UnsafePointer<Int8> = ("123" as NSString).UTF8String
            let unsafeStr: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.init(str)

            let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

            target.message_allSupportedParameters(objectParam, p2: target.dynamicType, p3: { x in x}, p4: -2, p5: -3, p6: -4, p7: -5,
                p8: 1, p9: 2, p10: 3, p11: 4, p12: 1.0, p13: 2.0, p14: str, p15: unsafeStr, p16: largeStruct)

            d.dispose()

            XCTAssertEqualAnyObjectArrayOfArrays(target.messages, messages)
        }
    }

    func _testMessageRecordedAndAllCallsAreMade<Result: Equatable>(selector: Selector, sendMessage: SentMessageTest_forwarding_basic -> Result, expectedResult: Result) {
        var observedMessages = [[AnyObject]]()
        var receivedDerivedClassMessage = [[AnyObject]]()
        var receivedBaseClassMessage = [[AnyObject]]()
        var completed = false

        var result: Result! = nil

        let action: () -> Disposable = { () -> Disposable in
            let target = SentMessageTest_forwarding_basic()

            let d = target.rx_sentMessage(selector).subscribe(onNext: { n in
                    observedMessages.append(n)
                }, onError: { e in
                    XCTFail("Errors out \(e)")
                }, onCompleted: {
                    completed = true
                })

            result = sendMessage(target)

            receivedDerivedClassMessage = target.messages
            receivedBaseClassMessage = target.baseMessages

            return d
        }

        action().dispose()

        XCTAssertEqual(result, expectedResult)
        XCTAssertTrue(completed)
        XCTAssert(observedMessages.count == 1)
        XCTAssertEqualAnyObjectArrayOfArrays(observedMessages, receivedDerivedClassMessage)
        XCTAssertEqualAnyObjectArrayOfArrays(observedMessages, receivedBaseClassMessage)
    }

    func testObservingByForwardingForAll() {
        let object = SentMessageTest_forwarding_basic()

        let closure: () -> () = {  }

        let constChar = ("you better be listening" as NSString).UTF8String

        let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

        _testMessageRecordedAndAllCallsAreMade("justCalledToSayObject:", sendMessage: { x in NSValue(nonretainedObject: x.justCalledToSayObject(object)) }, expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayClass:", sendMessage: { x in NSValue(nonretainedObject: x.justCalledToSayClass(object.dynamicType)) }, expectedResult: NSValue(nonretainedObject: object.dynamicType))
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayClosure:", sendMessage: { x in "\(x.justCalledToSayClosure(closure))" }, expectedResult: "\(closure)")
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayChar:", sendMessage: { x in x.justCalledToSayChar(3) }, expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayShort:", sendMessage: { x in x.justCalledToSayShort(4) }, expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayInt:", sendMessage: { x in x.justCalledToSayInt(5) }, expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayLong:", sendMessage: { x in x.justCalledToSayLong(6) }, expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayLongLong:", sendMessage: { x in x.justCalledToSayLongLong(7) }, expectedResult: 7)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayUnsignedChar:", sendMessage: { x in x.justCalledToSayUnsignedChar(8) }, expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayUnsignedShort:", sendMessage: { x in x.justCalledToSayUnsignedShort(9) }, expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayUnsignedInt:", sendMessage: { x in x.justCalledToSayUnsignedInt(10) }, expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayUnsignedLong:", sendMessage: { x in x.justCalledToSayUnsignedLong(11) }, expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayUnsignedLongLong:", sendMessage: { x in x.justCalledToSayUnsignedLongLong(12) }, expectedResult: 12)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayFloat:", sendMessage: { x in x.justCalledToSayFloat(13) }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayDouble:", sendMessage: { x in x.justCalledToSayDouble(13) }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayBool:", sendMessage: { x in x.justCalledToSayBool(true) }, expectedResult: true)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayConstChar:", sendMessage: { x in x.justCalledToSayConstChar(constChar) }, expectedResult: constChar)
        _testMessageRecordedAndAllCallsAreMade("justCalledToSayLarge:", sendMessage: { x in x.justCalledToSayLarge(largeStruct) }, expectedResult: 28)
    }

    func testObservingBySwizzlingForAll() {
        let object = SentMessageTest_forwarding_basic()

        let closure: () -> () = {  }

        let constChar = ("you better be listening" as NSString).UTF8String

        let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayObject:", sendMessage: { x in x.voidJustCalledToSayObject(object); return NSValue(nonretainedObject: object)  }, expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayClass:", sendMessage: { x in x.voidJustCalledToSayClass(object.dynamicType); return NSValue(nonretainedObject: object.dynamicType) }, expectedResult: NSValue(nonretainedObject: object.dynamicType))
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayClosure:", sendMessage: { x in x.voidJustCalledToSayClosure(closure); return "\(closure)" }, expectedResult: "\(closure)")
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayChar:", sendMessage: { x in x.voidJustCalledToSayChar(3); return 3 }, expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayShort:", sendMessage: { x in x.voidJustCalledToSayShort(4); return 4 }, expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayInt:", sendMessage: { x in x.voidJustCalledToSayInt(5); return 5 }, expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayLong:", sendMessage: { x in x.voidJustCalledToSayLong(6); return 6 }, expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayLongLong:", sendMessage: { x in x.voidJustCalledToSayLongLong(7); return 7 }, expectedResult: 7)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayUnsignedChar:", sendMessage: { x in x.voidJustCalledToSayUnsignedChar(8); return 8 }, expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayUnsignedShort:", sendMessage: { x in x.voidJustCalledToSayUnsignedShort(9); return 9 }, expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayUnsignedInt:", sendMessage: { x in x.voidJustCalledToSayUnsignedInt(10); return 10 }, expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayUnsignedLong:", sendMessage: { x in x.voidJustCalledToSayUnsignedLong(11); return 11 }, expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayUnsignedLongLong:", sendMessage: { x in x.voidJustCalledToSayUnsignedLongLong(12); return 12 }, expectedResult: 12)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayFloat:", sendMessage: { x in x.voidJustCalledToSayFloat(13); return 13 }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayDouble:", sendMessage: { x in x.voidJustCalledToSayDouble(13); return 13 }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayBool:", sendMessage: { x in x.voidJustCalledToSayBool(true); return true }, expectedResult: true)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayConstChar:", sendMessage: { x in x.voidJustCalledToSayConstChar(constChar); return constChar }, expectedResult: constChar)
        _testMessageRecordedAndAllCallsAreMade("voidJustCalledToSayLarge:", sendMessage: { x in x.voidJustCalledToSayLarge(largeStruct); return largeStruct }, expectedResult: largeStruct)
    }
}

extension SentMessageTest {

}

extension SentMessageTest {
    func performTestFirstOnNormalClassAndThenOnClassThatsActing<T: NSObject>(@autoclosure create: () -> T, action: (T, Bool) -> ()) {
        let firstTarget = create()
        action(firstTarget, false)

        let secondTarget = create()

        let state = ObjectRuntimeState(target: secondTarget)

        // observing using KVO creates a dynamic subclass that changes objc_
        let d = secondTarget.rx_observe(NSArray.self, "baseMessages")
            .subscribeNext { _ in
            }

        let afterKVO = ObjectRuntimeState(target: secondTarget)

        XCTAssert(afterKVO.changesFrom(state).real.classChanged)

        action(secondTarget, true)

        d.dispose()
    }
}


extension some_insanely_large_struct : Equatable {

}

public func ==(lhs: some_insanely_large_struct, rhs: some_insanely_large_struct) -> Bool {
    if lhs.a.0 != rhs.a.0 { return false }
    if lhs.a.1 != rhs.a.1 { return false }
    if lhs.a.2 != rhs.a.2 { return false }
    if lhs.a.3 != rhs.a.3 { return false }
    if lhs.a.4 != rhs.a.4 { return false }
    if lhs.a.5 != rhs.a.5 { return false }
    if lhs.a.6 != rhs.a.6 { return false }
    if lhs.a.7 != rhs.a.7 { return false }
    return lhs.some_large_text == rhs.some_large_text && lhs.next == rhs.next
}


// MARK: Experiments

typealias MethodParameters = [AnyObject]

extension SentMessageTest {

    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {

    }

    func createKVODynamicSubclassed<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(type: T.Type = T.self) -> () -> (T, [Disposable]) {
        return {
            let t = T()
            //let disposable = (t as! NSObject).rx_observe(NSArray.self, "messages").publish().connect()
            (t as! NSObject).addObserver(self, forKeyPath: "messages", options: [], context: nil)
            return (t, [AnonymousDisposable { (t as! NSObject).removeObserver(self, forKeyPath: "messages") }])
        }
    }

    func createNormalInstance<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(type: T.Type) -> () -> (T, [Disposable]) {
        return {
            return (T(), [])
        }
    }

    func _experimentWith<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(
        createIt: () -> (T, [Disposable]),
        observeIt: T -> [Observable<MethodParameters>],
        objectActingClassChange: [ObjectRuntimeChange],
        objectRealClassChange: [ObjectRuntimeChange],
        runtimeChange: RxObjCRuntimeChange,
        useIt: T -> [[MethodParameters]]
        ) {

        let originalRuntimeState = RxObjCRuntimeState()

        var createdObject: T = T()
        var disposables = [Disposable]()

        var nCompleted = 0
        var recordedParameters = [[MethodParameters]]()
        var observables: [Observable<MethodParameters>] = []

        autoreleasepool {
            (createdObject, disposables) = createIt()
            let afterCreateState = RxObjCRuntimeState()
            afterCreateState.assertAfterThisMoment(originalRuntimeState, changed:  RxObjCRuntimeChange.noChange)
        }

        let originalObjectRuntimeState = ObjectRuntimeState(target: createdObject)

        autoreleasepool {
            observables = observeIt(createdObject)
        }

        let afterObserveObjectRuntimeState = ObjectRuntimeState(target: createdObject)
        let afterObserveRuntimeState = RxObjCRuntimeState()

        let changesInRuntime = afterObserveObjectRuntimeState.changesFrom(originalObjectRuntimeState)
        XCTAssertEqual(Set(changesInRuntime.real), Set(objectRealClassChange))
        if (Set(changesInRuntime.real) != Set(objectRealClassChange)) {
            print("Actual changes in real runtime:\n\(changesInRuntime.real)\n\nExpected changes in real runtime:\n\(objectRealClassChange)\n\n")
        }
        XCTAssertEqual(Set(changesInRuntime.actingAs), Set(objectActingClassChange))
        if (Set(changesInRuntime.actingAs) != Set(objectActingClassChange)) {
            print("Actual changes in acting runtime:\n\(changesInRuntime.actingAs)\n\nExpected changes in acting runtime:\n\(objectActingClassChange)\n\n")
        }
        afterObserveRuntimeState.assertAfterThisMoment(originalRuntimeState, changed: runtimeChange)

        autoreleasepool {
            var i = 0

            for o in observables {
                let index = i++
                recordedParameters.append([])
                _ = o.subscribe(onNext: { n in
                        recordedParameters[index].append(n)
                    }, onError: { e in
                        XCTFail("Error happened \(e)")
                    }, onCompleted: { () -> Void in
                        nCompleted++
                    })
            }
        }

        let expectedParameters = useIt(createdObject)

        let finalObjectRuntimeState = ObjectRuntimeState(target: createdObject)

        let finalChangesInRuntime = finalObjectRuntimeState.changesFrom(afterObserveObjectRuntimeState)
        XCTAssertTrue(finalChangesInRuntime.actingAs.count == 0)
        XCTAssertTrue(finalChangesInRuntime.real.count == 0)

        autoreleasepool {
            for d in disposables {
                d.dispose()
            }
            disposables = []

            // tiny second test to make sure runtime stayed intact
            createdObject = T()
        }

        // ensure all observables are completed on object dispose
        XCTAssertTrue(nCompleted == observables.count)

        XCTAssertEqual(recordedParameters.count, expectedParameters.count)
        for (lhs, rhs) in zip(recordedParameters, expectedParameters) {
            XCTAssertEqualAnyObjectArrayOfArrays(lhs, rhs)
        }

        // nothing is changed after requesting the observables
        let endRuntimeState = RxObjCRuntimeState()
        endRuntimeState.assertAfterThisMoment(afterObserveRuntimeState, changed: RxObjCRuntimeChange.noChange)
    }

    func experimentWith<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(
        createIt: () -> (T, [Disposable]),
        observeIt: T -> [Observable<MethodParameters>],
        objectActingClassChange: [ObjectRuntimeChange],
        objectRealClassChange: [ObjectRuntimeChange],
        runtimeChange: RxObjCRuntimeChange,
        useIt: T -> [[MethodParameters]]
        ) {
        // First run normal experiment
        _experimentWith(createIt,
            observeIt: observeIt,
            objectActingClassChange: objectActingClassChange,
            objectRealClassChange: objectRealClassChange,
            runtimeChange: runtimeChange,
            useIt: useIt
            )

        // The second run of the same experiment shouldn't cause any changes in global runtime.
        // Cached methods should be used.
        // If second experiment causes some change in runtime, that means there is a bug.
        _experimentWith(createIt,
            observeIt: observeIt,
            objectActingClassChange: [],
            objectRealClassChange: objectRealClassChange,
            runtimeChange: RxObjCRuntimeChange.noChange,
            useIt: useIt
        )
    }
}
