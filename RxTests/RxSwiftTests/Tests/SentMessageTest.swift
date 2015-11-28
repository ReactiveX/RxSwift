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
    func dynamicClassName(baseClassName: String) -> String {
        return "_RX_namespace_" + baseClassName
    }
}

// MARK: Dynamic class generation

extension SentMessageTest {

    func testActing_forwarding() {
        experimentWith(
            createKVODynamicSublassed(SendMessageTest_acting_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [ObjectRuntimeChange.ForwardImplementationAdded(forSelector: "justCalledToSayObject:")],
            objectRealClassChange: [],
            runtimeChange: RxObjCRuntimeChange.generatedNewClassWith(swizzledMethods: 1, hasSwizzledForward: false)) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // after that normal
        experimentWith(
            createNormalInstance(SendMessageTest_acting_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage("justCalledToSayObject:")]
            },
            objectActingClassChange: [],
            objectRealClassChange: [ObjectRuntimeChange.ClassChangedToDynamic("SendMessageTest_acting_forwarding", andImplementsTheseSelectors: ["justCalledToSayObject:"])],
            runtimeChange: RxObjCRuntimeChange.generatedNewClassWith(swizzledMethods: 1, hasSwizzledForward: false)) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }
    }
}

// MARK: Forwarding

extension SentMessageTest {

    func testNormal_forwarding() {
    }

    /*
    func testBasicForwardingCase() {
        performTestFirstOnNormalClassAndThenOnClassThatsActing(ObjcSendMessageTest_forwarding_basic()) { target, isActing in
            var messages = [[AnyObject]]()

            let initialState = ObjectRuntimeState(target: target)

            let d = target.rx_sentMessage("message_allSupportedParameters:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:").subscribe(onNext: { n in
                    messages.append(n)
                }, onError: { e in
                    XCTFail("Errors out \(e)")
                })

            let finalState = ObjectRuntimeState(target: target)

            let str: UnsafePointer<Int8> = ("123" as NSString).UTF8String
            let unsafeStr: UnsafeMutablePointer<Int8> = UnsafeMutablePointer.init(str)

            let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

            target.message_allSupportedParameters(target, p2: target.dynamicType, p3: { x in x}, p4: -2, p5: -3, p6: -4, p7: -5,
                p8: 1, p9: 2, p10: 3, p11: 4, p12: 1.0, p13: 2.0, p14: str, p15: unsafeStr, p16: largeStruct)

            d.dispose()

            XCTAssertEqualAnyObjectArrayOfArrays(target.messages, messages)
        }
    }

    func _testMessageRecordedAndAllCallsAreMade<Result: Equatable>(selector: Selector, sendMessage: ObjcSendMessageTest_forwarding_basic -> Result, expectedResult: Result) {
        var observedMessages = [[AnyObject]]()
        var receivedDerivedClassMessage = [[AnyObject]]()
        var receivedBaseClassMessage = [[AnyObject]]()
        var completed = false

        var result: Result! = nil

        let action: () -> Disposable = { () -> Disposable in
            let target = ObjcSendMessageTest_forwarding_basic()

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
        let object = ObjcSendMessageTest_forwarding_basic()

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
    */
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

        action(firstTarget, true)

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
    func createKVODynamicSublassed<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(type: T.Type) -> () -> (T, [Disposable]) {
        return {
            let t = T()
            let disposable = (t as! NSObject).rx_observe(NSArray.self, "messages").publish().connect()
            return (t, [disposable])
        }
    }

    func createNormalInstance<T: SentMessageTestClassCreationProtocol>(type: T.Type) -> () -> (T, [Disposable]) {
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

        var (createdObject, disposables) = createIt()
        let afterCreateState = RxObjCRuntimeState()
        afterCreateState.assertAfterThisMoment(originalRuntimeState, changed:  RxObjCRuntimeChange.noChange)

        let originalObjectRuntimeState = ObjectRuntimeState(target: createdObject)

        let observables = observeIt(createdObject)

        let afterObserveObjectRuntimeState = ObjectRuntimeState(target: createdObject)
        let afterObserveRuntimeState = RxObjCRuntimeState()

        let changesInRuntime = afterObserveObjectRuntimeState.changesFrom(originalObjectRuntimeState)
        XCTAssertEqual(Set(changesInRuntime.real), Set(objectRealClassChange))
        XCTAssertEqual(Set(changesInRuntime.actingAs), Set(objectRealClassChange))
        afterObserveRuntimeState.assertAfterThisMoment(originalRuntimeState, changed: runtimeChange)

        var nCompleted = 0

        var recordedParameters = [[MethodParameters]]()

        var i = 0
        for o in observables {
            let index = i++
            recordedParameters.append([])
            _ = o.subscribe(onNext: { n in
                    recordedParameters[index].append(n)
                }, onError: { e in
                    XCTFail("Error happene \(e)")
                }, onCompleted: { () -> Void in
                    nCompleted++
                })
        }

        let expectedParameters = useIt(createdObject)

        for d in disposables {
            d.dispose()
        }

        // dealloc old object
        (createdObject, disposables) = createIt()
        for d in disposables {
            d.dispose()
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
            objectActingClassChange: objectActingClassChange,
            objectRealClassChange: objectRealClassChange,
            runtimeChange: RxObjCRuntimeChange.noChange,
            useIt: useIt
        )
    }
}
