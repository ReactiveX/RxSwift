//
//  SentMessageTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 11/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
import RxCocoa
import RxBlocking

class SentMessageTest : RxTest {
    var testClosure: () -> () = { }

    func dynamicClassName(baseClassName: String) -> String {
        return "_RX_namespace_" + baseClassName
    }
}

// MARK: Observing dealloc 

extension SentMessageTest {
    func testDealloc_baseClass_subClass_dont_interact1() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact2() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc2) in
                return [target.rx_deallocating.map { _ in [] }]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc2) in
                return [target.rx_deallocating.map { _ in [] }]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_base_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_base) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_base) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_subclass_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_subclass) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_subclass) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_base_subclass_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_base_subclass) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_base_subclass) in
                return [target.rx_sentMessage(NSSelectorFromString("dealloc"))]
            },
            objectActingClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .ImplementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, interceptedClasses: 1),
            useIt: { _ in return [[[]]]})
    }
}

// MARK: Observing by forwarding

extension SentMessageTest {
    func testBaseClass_subClass_dont_interact_for_forwarding() {
        // first forwarding with normal first
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTest_interact_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayObject(_:)))]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledToSayObject(_:)),
                    NSSelectorFromString("_RX_namespace_justCalledToSayObject:"),
                ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses:1, methodsForwarded: 1, swizzledForwardClasses: 1)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then forwarding base class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTestBase_interact_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayObject(_:)))]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTestBase_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledToSayObject(_:)),
                    NSSelectorFromString("_RX_namespace_justCalledToSayObject:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses:1, methodsForwarded: 1, swizzledForwardClasses: 1)
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }


        // then normal again, no changes
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTest_interact_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayObject(_:)))]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledToSayObject(_:)),
                    NSSelectorFromString("_RX_namespace_justCalledToSayObject:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes()
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }

        // then dynamic again, no changes
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTestBase_interact_forwarding.self),
            observeIt: { target in
                return [target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayObject(_:)))]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTestBase_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledToSayObject(_:)),
                    NSSelectorFromString("_RX_namespace_justCalledToSayObject:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes()
            ) { target in
                let o = NSObject()
                target.justCalledToSayObject(o)
                return [[[o]]]
        }
    }


}

// MARK: Optimized observers don't interfere between class/baseclass

extension SentMessageTest {
    func testBaseClass_subClass_dont_interact_for_optimized_version_void() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_void.self,
            SentMessageTest_optimized_void.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayVoid)) { target in
            target.voidJustCalledToSayVoid()
            return [[[]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id.self,
            SentMessageTest_optimized_id.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayObject(_:))) { target in
            let o = NSObject()
            target.voidJustCalledToSayObject(o)
            return [[[o]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_int() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_int.self,
            SentMessageTest_optimized_int.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayInt(_:))) { target in
            target.voidJustCalledToSayInt(3)
            return [[[NSNumber(integer: 3)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_long() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_long.self,
            SentMessageTest_optimized_long.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayLong(_:))) { target in
            target.voidJustCalledToSayLong(3)
            return [[[NSNumber(long: 3)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_char() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_char.self,
            SentMessageTest_optimized_char.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayChar(_:))) { target in
            target.voidJustCalledToSayChar(3)
            return [[[NSNumber(char: 3)]]]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id_id.self,
            SentMessageTest_optimized_id_id.self,
            #selector(SentMessageTestBase_shared.voidJustCalledToSayObject(_:object:))) { target in
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
        // now force forwarding mechanism for normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { target in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(targetClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, dynamicSubclasses: 1)) { (target: TargetClass) in
                return invoke(target as! BaseClass)
        }

        // first force base class forwarding
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: BaseClass) in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [

            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(baseClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(methodsSwizzled: 1, dynamicSubclasses: 1),
            useIt: invoke)

        // now force forwarding mechanism for normal class again
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { target in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(targetClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes()) { (target: TargetClass) in
                return invoke(target as! BaseClass)
        }

        // forwarding for base class again
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: BaseClass) in
                return [(target as! NSObject).rx_sentMessage(method)]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(baseClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(),
            useIt: invoke)

    }
}

// MARK: Optimized observers don't interfere between class/baseclass depending on who is implementing the method

extension SentMessageTest {
    func testBaseClass_subClass_dont_interact_for_optimized_version_int_base_implements() {
        let argument = NSObject()
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_int_base.self,
            SentMessageTest_optimized_int_base.self,
            #selector(SentMessageTestBase_optimized_int_base.optimized(_:))) { target in
                target.optimized(argument)
                return [[[argument]]]
        }
    }
}

// MARK: Basic observing by forwarding cases

extension SentMessageTest {
    func testBasicForwardingCase() {
        let target = SentMessageTest_forwarding_basic()
        var messages = [[AnyObject]]()

        let d = target.rx_sentMessage(#selector(SentMessageTestBase_shared.message_allSupportedParameters(_:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:))).subscribe(onNext: { n in
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

// MARK: Test failures

extension SentMessageTest {
    func testFailsInCaseObservingUnknownSelector() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(NSSelectorFromString("unknownSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .SelectorNotImplemented(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithKVO() {
        let target = SentMessageTest_shared()

        let disposeBag = DisposeBag()
        target.rx_observe(NSArray.self, "messages")
            .subscribeNext { _ in
            }
            .addDisposableTo(disposeBag)

        do {
            _ = try target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayBool(_:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObjectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.KVO)
        }
    }

    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithSomeOtherMechanism() {
        let target = SentMessageTest_shared()

        object_setClass(target, SentMessageTest_shared_mock_interceptor.self)

        do {
            _ = try target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayBool(_:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObjectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.KVO)
        }
    }

    func testFailsInCaseObjectIsCF() {
        autoreleasepool {
            let target = "\(NSDate())"

            do {
                _ = try target.rx_sentMessage(#selector(_NSStringCoreType.length))
                    .toBlocking()
                    .first()

                XCTFail()
            }
            catch let e {
                guard case .CantInterceptCoreFoundationTollFreeBridgedObjects(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual(targetInError as? NSString, target)
            }
        }
    }

}

// MARK: Test interaction with KVO

extension SentMessageTest {
    func testWorksWithKVOInCaseKVORegisteredAfter() {
        let target = SentMessageTest_shared()

        let messages = target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayBool(_:)))

        let kvo = target.rx_observe(NSArray.self, "messages")
            .subscribeNext { _ in
            }

        var recordedMessages = [MethodParameters]()
        let methodObserving = messages.subscribeNext { n in
            recordedMessages.append(n)
        }

        target.justCalledToSayBool(true)

        kvo.dispose()

        target.justCalledToSayBool(false)

        XCTAssertEqual(recordedMessages, [[NSNumber(bool: true)], [NSNumber(bool: false)]])

        methodObserving.dispose()
    }
}

// MARK: Test subjects

extension SentMessageTest {
    func testMessageSentSubjectHasPublishBehavior() {
        var messages: Observable<MethodParameters>!
        var recordedMessages = [MethodParameters]()
        var completed = false
        let disposeBag = DisposeBag()

        autoreleasepool {
            let target = SentMessageTest_shared()

            messages = target.rx_sentMessage(#selector(SentMessageTestBase_shared.justCalledToSayBool(_:)))

            target.justCalledToSayBool(true)

            messages.subscribe(onNext: { n in
                recordedMessages.append(n)
            }, onCompleted: {
                completed = true
            }).addDisposableTo(disposeBag)

            target.justCalledToSayBool(true)

        }

        XCTAssertEqual(recordedMessages, [[NSNumber(bool: true)]])
        XCTAssertTrue(completed)
    }

    func testDeallocSubjectHasReplayBehavior1() {
        var deallocSequence: Observable<MethodParameters>!
        autoreleasepool {
            let target = SentMessageTest_shared()

            deallocSequence = target.rx_sentMessage(NSSelectorFromString("dealloc"))
        }

        var called = false
        var completed = false
        _ = deallocSequence.subscribe(onNext: { n in
            called = true
        }, onCompleted: {
            completed = true
        })

        XCTAssertTrue(called)
        XCTAssertTrue(completed)
    }

    func testDeallocSubjectHasReplayBehavior2() {
        var deallocSequence: Observable<()>!
        autoreleasepool {
            let target = SentMessageTest_shared()

            deallocSequence = target.rx_deallocating
        }

        var called = false
        var completed = false
        _ = deallocSequence.subscribe(onNext: { n in
            called = true
        }, onCompleted: {
            completed = true
        })

        XCTAssertTrue(called)
        XCTAssertTrue(completed)
    }
}

// MARK: Test observing of special methods fail

extension SentMessageTest {
    func testObserve_special_class() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(NSSelectorFromString("class"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObservingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_forwardingTargetForSelector() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(NSSelectorFromString("forwardingTargetForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObservingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_methodSignatureForSelector() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(NSSelectorFromString("methodSignatureForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObservingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_respondsToSelector() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(NSSelectorFromString("respondsToSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObservingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }
}

// MARK: Test return value check

extension SentMessageTest {
    func testObserve_largeStructReturnValueFails() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx_sentMessage(#selector(SentMessageTestBase_shared.hugeResult))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .ObservingMessagesWithUnsupportedReturnType(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }
}

// MARK: Ensure all types are covered

extension SentMessageTest {
    func testObservingForAllTypes() {
        let object = SentMessageTest_all_supported_types()

        let closure: () -> () = {  }

        let constChar = ("you better be listening" as NSString).UTF8String

        let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

        let startRuntimeState = RxObjCRuntimeState()

        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayObject(_:)), sendMessage: { x in NSValue(nonretainedObject: x.justCalledToSayObject(object)) }, expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayClass(_:)), sendMessage: { x in NSValue(nonretainedObject: x.justCalledToSayClass(object.dynamicType)) }, expectedResult: NSValue(nonretainedObject: object.dynamicType))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayClosure(_:)), sendMessage: { x in "\(x.justCalledToSayClosure(closure))" }, expectedResult: "\(closure)")
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayChar(_:)), sendMessage: { x in x.justCalledToSayChar(3) }, expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayShort(_:)), sendMessage: { x in x.justCalledToSayShort(4) }, expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayInt(_:)), sendMessage: { x in x.justCalledToSayInt(5) }, expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayLong(_:)), sendMessage: { x in x.justCalledToSayLong(6) }, expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayLongLong(_:)), sendMessage: { x in x.justCalledToSayLongLong(7) }, expectedResult: 7)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayUnsignedChar(_:)), sendMessage: { x in x.justCalledToSayUnsignedChar(8) }, expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayUnsignedShort(_:)), sendMessage: { x in x.justCalledToSayUnsignedShort(9) }, expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayUnsignedInt(_:)), sendMessage: { x in x.justCalledToSayUnsignedInt(10) }, expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayUnsignedLong(_:)), sendMessage: { x in x.justCalledToSayUnsignedLong(11) }, expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayUnsignedLongLong(_:)), sendMessage: { x in x.justCalledToSayUnsignedLongLong(12) }, expectedResult: 12)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayFloat(_:)), sendMessage: { x in x.justCalledToSayFloat(13) }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayDouble(_:)), sendMessage: { x in x.justCalledToSayDouble(13) }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayBool(_:)), sendMessage: { x in x.justCalledToSayBool(true) }, expectedResult: true)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayConstChar(_:)), sendMessage: { x in x.justCalledToSayConstChar(constChar) }, expectedResult: constChar)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledToSayLarge(_:)), sendMessage: { x in x.justCalledToSayLarge(largeStruct) }, expectedResult: 28)

        let middleRuntimeState = RxObjCRuntimeState()

        let middleChanges = RxObjCRuntimeChange.changes(methodsForwarded: 18, dynamicSubclasses: 1, swizzledForwardClasses: 1)
        middleRuntimeState.assertAfterThisMoment(startRuntimeState, changed:middleChanges)

        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayObject(_:)), sendMessage: { x in x.voidJustCalledToSayObject(object); return NSValue(nonretainedObject: object)  }, expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayClosure(_:)), sendMessage: { x in x.voidJustCalledToSayClosure(closure); return "\(closure)" }, expectedResult: "\(closure)")
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayChar(_:)), sendMessage: { x in x.voidJustCalledToSayChar(3); return 3 }, expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayShort(_:)), sendMessage: { x in x.voidJustCalledToSayShort(4); return 4 }, expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayInt(_:)), sendMessage: { x in x.voidJustCalledToSayInt(5); return 5 }, expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayLong(_:)), sendMessage: { x in x.voidJustCalledToSayLong(6); return 6 }, expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayUnsignedChar(_:)), sendMessage: { x in x.voidJustCalledToSayUnsignedChar(8); return 8 }, expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayUnsignedShort(_:)), sendMessage: { x in x.voidJustCalledToSayUnsignedShort(9); return 9 }, expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayUnsignedInt(_:)), sendMessage: { x in x.voidJustCalledToSayUnsignedInt(10); return 10 }, expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayUnsignedLong(_:)), sendMessage: { x in x.voidJustCalledToSayUnsignedLong(11); return 11 }, expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayFloat(_:)), sendMessage: { x in x.voidJustCalledToSayFloat(13); return 13 }, expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledToSayDouble(_:)), sendMessage: { x in x.voidJustCalledToSayDouble(13); return 13 }, expectedResult: 13)

        let endRuntimeState = RxObjCRuntimeState()

        endRuntimeState.assertAfterThisMoment(middleRuntimeState, changed: RxObjCRuntimeChange.changes(methodsSwizzled: 12))

    }

    func _testMessageRecordedAndAllCallsAreMade<Result: Equatable>(selector: Selector, sendMessage: SentMessageTest_all_supported_types -> Result, expectedResult: Result) {
        var observedMessages = [[AnyObject]]()
        var receivedDerivedClassMessage = [[AnyObject]]()
        var receivedBaseClassMessage = [[AnyObject]]()
        var completed = false

        var result: Result! = nil

        let action: () -> Disposable = { () -> Disposable in
            let target = SentMessageTest_all_supported_types()

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
}

extension SentMessageTest {
    /**
     Repeats action twice and makes sure there is no global leaks. Observing mechanism is lazy loaded so not caching
     results properly can cause serious memory leaks.
    */
    func ensureGlobalRuntimeChangesAreCached<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(
        createIt: () -> (T, [Disposable]),
        observeIt: T -> [Observable<MethodParameters>],
        objectActingClassChange: [ObjectRuntimeChange],
        objectRealClassChange: [ObjectRuntimeChange],
        runtimeChange: RxObjCRuntimeChange,
        useIt: T -> [[MethodParameters]]
        ) {
        // First run normal experiment
        _ensureGlobalRuntimeChangesAreCached(createIt,
            observeIt: observeIt,
            expectedActingClassChanges: objectActingClassChange,
            expectedRealClassChanges: objectRealClassChange,
            runtimeChange: runtimeChange,
            useIt: useIt
            )



        // The second run of the same experiment shouldn't cause any changes in global runtime.
        // Cached methods should be used.
        // If second experiment causes some change in runtime, that means there is a bug.
        _ensureGlobalRuntimeChangesAreCached(createIt,
            observeIt: observeIt,
            expectedActingClassChanges: [], // acting class can't change second time, because that would mean that on every observe attempt we would inject new methods in runtime
            expectedRealClassChanges: objectRealClassChange.filter { $0.isClassChange }, // only class can change to the same class it changed originally
            runtimeChange: RxObjCRuntimeChange.changes(),
            useIt: useIt
        )

    }

    func _ensureGlobalRuntimeChangesAreCached<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(
        createIt: () -> (T, [Disposable]),
        observeIt: T -> [Observable<MethodParameters>],
        expectedActingClassChanges: [ObjectRuntimeChange],
        expectedRealClassChanges: [ObjectRuntimeChange],
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
            afterCreateState.assertAfterThisMoment(originalRuntimeState, changed:  RxObjCRuntimeChange.changes())
        }

        let originalObjectRuntimeState = ObjectRuntimeState(target: createdObject)

        autoreleasepool {
            observables = observeIt(createdObject)
        }

        let afterObserveObjectRuntimeState = ObjectRuntimeState(target: createdObject)
        let afterObserveRuntimeState = RxObjCRuntimeState()

        afterObserveObjectRuntimeState.assertChangesFrom(originalObjectRuntimeState,
            expectedActingClassChanges: expectedActingClassChanges,
            expectedRealClassChanges: expectedRealClassChanges
        )
        afterObserveRuntimeState.assertAfterThisMoment(originalRuntimeState, changed: runtimeChange)

        autoreleasepool {
            var i = 0

            for o in observables {
                let index = i
                i += 1
                recordedParameters.append([])
                _ = o.subscribe(onNext: { n in
                        recordedParameters[index].append(n)
                    }, onError: { e in
                        XCTFail("Error happened \(e)")
                    }, onCompleted: { () -> Void in
                        nCompleted += 1
                    })
            }
        }

        let expectedParameters = useIt(createdObject)

        let finalObjectRuntimeState = ObjectRuntimeState(target: createdObject)

        finalObjectRuntimeState.assertChangesFrom(afterObserveObjectRuntimeState,
            expectedActingClassChanges: [],
            expectedRealClassChanges: []
        )

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
        endRuntimeState.assertAfterThisMoment(afterObserveRuntimeState, changed: RxObjCRuntimeChange.changes())
    }

}

// MARK: Convenience

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

    func createNormalInstance<T: protocol<SentMessageTestClassCreationProtocol, NSObjectProtocol>>(type: T.Type = T.self) -> () -> (T, [Disposable]) {
        return {
            return (T(), [])
        }
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

typealias MethodParameters = [AnyObject]
