//
//  SentMessageTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxCocoa
import RxBlocking

final class SentMessageTest: RxTest {
    var testClosure: () -> Void = { }

    func dynamicClassName(_ baseClassName: String) -> String {
        "_RX_namespace_" + baseClassName
    }
}

// MARK: Observing dealloc 

extension SentMessageTest {
    func testDealloc_baseClass_subClass_dont_interact1() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact1_invokedMessage() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc) in
                return [.methodInvoked(target.rx.methodInvoked(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                ],
            objectRealClassChange: [
                ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 0, methodsSwizzled: 0),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc) in
                return [.methodInvoked(target.rx.methodInvoked(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                ],
            objectRealClassChange: [
                ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 0, methodsSwizzled: 0),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact2() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc2) in
                return [.sentMessage(target.rx.deallocating.map { _ in [] })]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc2) in
                return [.sentMessage(target.rx.deallocating.map { _ in [] })]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_base_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_base) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_base) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_base_implements_invokedMessage() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_base) in
                return [.methodInvoked(target.rx.methodInvoked(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                ],
            objectRealClassChange: [
                ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 0, methodsSwizzled: 0),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_base) in
                return [.methodInvoked(target.rx.methodInvoked(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                ],
            objectRealClassChange: [
                ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 0, methodsSwizzled: 0),
            useIt: { _ in return [[[]]]})
    }


    func testDealloc_baseClass_subClass_dont_interact_subclass_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_subclass) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationAdded(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_subclass) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})
    }

    func testDealloc_baseClass_subClass_dont_interact_base_subclass_implements() {
        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTestBase_dealloc_base_subclass) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
            useIt: { _ in return [[[]]]})

        // swizzle normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: SentMessageTest_dealloc_base_subclass) in
                return [.sentMessage(target.rx.sentMessage(NSSelectorFromString("dealloc")))]
            },
            objectActingClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            objectRealClassChange: [
                .implementationChanged(forSelector: NSSelectorFromString("dealloc")),
            ],
            runtimeChange: RxObjCRuntimeChange.changes(interceptedClasses: 1, methodsSwizzled: 1),
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
                return [
                    ObservedSequence.sentMessage(target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledObject(toSay:)))),
                    ObservedSequence.methodInvoked(target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledObject(toSay:))))
                ]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledObject(toSay:)),
                    NSSelectorFromString("_RX_namespace_justCalledObjectToSay:"),
                ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses:1, swizzledForwardClasses: 1, methodsForwarded: 1)
            ) { target in
                let o = NSObject()
                target.justCalledObject(toSay: o)
                return [
                    [[o]],
                    [[o]]
                ]
        }

        // then forwarding base class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTestBase_interact_forwarding.self),
            observeIt: { target in
                return [
                    ObservedSequence.sentMessage(target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledObject(toSay:)))),
                    ObservedSequence.methodInvoked(target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledObject(toSay:))))
                ]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTestBase_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledObject(toSay:)),
                    NSSelectorFromString("_RX_namespace_justCalledObjectToSay:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses:1, swizzledForwardClasses: 1, methodsForwarded: 1)
            ) { target in
                let o = NSObject()
                target.justCalledObject(toSay: o)
                return [
                    [[o]],
                    [[o]]
                ]
        }


        // then normal again, no changes
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTest_interact_forwarding.self),
            observeIt: { target in
                return [
                    ObservedSequence.sentMessage(target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledObject(toSay:)))),
                    ObservedSequence.methodInvoked(target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledObject(toSay:))))
                ]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTest_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledObject(toSay:)),
                    NSSelectorFromString("_RX_namespace_justCalledObjectToSay:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes()
            ) { target in
                let o = NSObject()
                target.justCalledObject(toSay: o)
                return [
                    [[o]],
                    [[o]]
                ]
        }

        // then dynamic again, no changes
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(SentMessageTestBase_interact_forwarding.self),
            observeIt: { target in
                return [
                    ObservedSequence.sentMessage(target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledObject(toSay:)))),
                    ObservedSequence.methodInvoked(target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledObject(toSay:))))
                ]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("SentMessageTestBase_interact_forwarding", andImplementsTheseSelectors: [
                    NSSelectorFromString("class"),
                    NSSelectorFromString("respondsToSelector:"),
                    NSSelectorFromString("methodSignatureForSelector:"),
                    NSSelectorFromString("forwardInvocation:"),
                    #selector(SentMessageTestBase_shared.justCalledObject(toSay:)),
                    NSSelectorFromString("_RX_namespace_justCalledObjectToSay:"),
                    ])
            ],
            runtimeChange: RxObjCRuntimeChange.changes()
            ) { target in
                let o = NSObject()
                target.justCalledObject(toSay: o)
                return [
                    [[o]],
                    [[o]]
                ]
        }
    }


}

// MARK: Optimized observers don't interfere between class/baseclass

extension SentMessageTest {
    func testBaseClass_subClass_dont_interact_for_optimized_version_void() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_void.self,
            SentMessageTest_optimized_void.self,
            #selector(SentMessageTestBase_shared.voidJustCalledVoidToSay)) { target in
            target.voidJustCalledVoidToSay()
            return [
                [[]],
                [[]]
            ]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id.self,
            SentMessageTest_optimized_id.self,
            #selector(SentMessageTestBase_shared.voidJustCalledObject(toSay:))) { target in
            let o = NSObject()
            target.voidJustCalledObject(toSay: o)
            return [
                [[o]],
                [[o]]
            ]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_int() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_int.self,
            SentMessageTest_optimized_int.self,
            #selector(SentMessageTestBase_shared.voidJustCalledInt(toSay:))) { target in
            target.voidJustCalledInt(toSay: 3)
            return [
                [[NSNumber(value: 3)]],
                [[NSNumber(value: 3)]]
            ]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_long() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_long.self,
            SentMessageTest_optimized_long.self,
            #selector(SentMessageTestBase_shared.voidJustCalledLong(toSay:))) { target in
            target.voidJustCalledLong(toSay: 3)
            return [
                [[NSNumber(value: 3)]],
                [[NSNumber(value: 3)]]
            ]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_char() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_char.self,
            SentMessageTest_optimized_char.self,
            #selector(SentMessageTestBase_shared.voidJustCalledChar(toSay:))) { target in
            target.voidJustCalledChar(toSay: 3)
            return [
                [[NSNumber(value: 3)]],
                [[NSNumber(value: 3)]]
            ]
        }
    }

    func testBaseClass_subClass_dont_interact_for_optimized_version_id_id() {
        _baseClass_subClass_dont_interact_for_optimized_version(
            SentMessageTestBase_optimized_id_id.self,
            SentMessageTest_optimized_id_id.self,
            #selector(SentMessageTestBase_shared.voidJustCalledObject(toSay:object:))) { target in
            let o = NSObject()
            let o1 = NSObject()
            target.voidJustCalledObject(toSay: o, object: o1)
            return [
                [[o, o1]],
                [[o, o1]]
            ]
        }
    }

    func _baseClass_subClass_dont_interact_for_optimized_version
    <
        BaseClass: SentMessageTestClassCreationProtocol & NSObjectProtocol,
        TargetClass: SentMessageTestClassCreationProtocol & NSObjectProtocol
    >(_ baseClass: BaseClass.Type, _ targetClass: TargetClass.Type, _ method: Selector, _ invoke: @escaping (BaseClass) -> [[MethodParameters]]) {
        // now force forwarding mechanism for normal class
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { target in
                return [
                   .sentMessage((target as! NSObject).rx.sentMessage(method)),
                   .methodInvoked((target as! NSObject).rx.methodInvoked(method)),
                ]
            },
            objectActingClassChange: [
            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(targetClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses: 1, methodsSwizzled: 1)) { (target: TargetClass) in
                return invoke(target as! BaseClass)
        }

        // first force base class forwarding
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { (target: BaseClass) in
                return [
                    .sentMessage((target as! NSObject).rx.sentMessage(method)),
                    .methodInvoked((target as! NSObject).rx.methodInvoked(method)),
                    ]
            },
            objectActingClassChange: [

            ],
            objectRealClassChange: [
                ObjectRuntimeChange.ClassChangedToDynamic("\(baseClass)", andImplementsTheseSelectors: [method, NSSelectorFromString("class")])
            ],
            runtimeChange: RxObjCRuntimeChange.changes(dynamicSubclasses: 1, methodsSwizzled: 1),
            useIt: invoke)

        // now force forwarding mechanism for normal class again
        ensureGlobalRuntimeChangesAreCached(
            createNormalInstance(),
            observeIt: { target in
                return [
                    .sentMessage((target as! NSObject).rx.sentMessage(method)),
                    .methodInvoked((target as! NSObject).rx.methodInvoked(method)),
                ]
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
                return [
                    .sentMessage((target as! NSObject).rx.sentMessage(method)),
                    .methodInvoked((target as! NSObject).rx.methodInvoked(method)),
                ]
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
                return [
                    [[argument]],
                    [[argument]]
                ]
        }
    }
}

// MARK: Basic observing by forwarding cases

extension SentMessageTest {
    func testBasicForwardingCase() {
        let target = SentMessageTest_forwarding_basic()
        var messages = [[Any]]()
        var messageStage: [MessageProcessingStage] = []

        let d = target.rx.sentMessage(#selector(SentMessageTestBase_shared.message_allSupportedParameters(_:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:))).subscribe(onNext: { n in
                messages.append(n)
                messageStage.append(.sentMessage)
            }, onError: { e in
                XCTFail("Errors out \(e)")
            })

        let d2 = target.rx.methodInvoked(#selector(SentMessageTestBase_shared.message_allSupportedParameters(_:p2:p3:p4:p5:p6:p7:p8:p9:p10:p11:p12:p13:p14:p15:p16:))).subscribe(onNext: { n in
                messages.append(n)
                messageStage.append(.methodInvoked)
            }, onError: { e in
                XCTFail("Errors out \(e)")
            })

        let objectParam = NSObject()
        let str: UnsafePointer<Int8> = UnsafePointer(bitPattern: 1343423)!
        let unsafeStr: UnsafeMutablePointer<Int8> = UnsafeMutablePointer(bitPattern: 2123123)!

        let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

        target.invokedMethod = {
            messageStage.append(.invoking)
        }
        
        target.message_allSupportedParameters(objectParam, p2: type(of: target), p3: { x in x}, p4: -2, p5: -3, p6: -4, p7: -5,
            p8: 1, p9: 2, p10: 3, p11: 4, p12: 1.0, p13: 2.0, p14: str, p15: unsafeStr, p16: largeStruct)

        d.dispose()
        d2.dispose()

        let resultMessages = target.messages.map { $0.values }
        XCTAssertEqualAnyObjectArrayOfArrays(resultMessages + resultMessages, messages)
        XCTAssertEqual(messageStage, [.sentMessage, .invoking, .methodInvoked])
    }
}

// MARK: Test failures

extension SentMessageTest {
    func testFailsInCaseObservingUnknownSelector_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(NSSelectorFromString("unknownSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .selectorNotImplemented(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testFailsInCaseObservingUnknownSelector_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(NSSelectorFromString("unknownSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .selectorNotImplemented(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }


    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithKVO_sentMessage() {
        let target = SentMessageTest_shared()

        let disposeBag = DisposeBag()
        target.rx.observe(NSArray.self, "messages")
            .subscribe(onNext: { _ in
            })
            .disposed(by: disposeBag)

        do {
            _ = try target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .objectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.kvo)
        }
    }

    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithKVO_methodInvoked() {
        let target = SentMessageTest_shared()

        let disposeBag = DisposeBag()
        target.rx.observe(NSArray.self, "messages")
            .subscribe(onNext: { _ in
            })
            .disposed(by: disposeBag)

        do {
            _ = try target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .objectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.kvo)
        }
    }

    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithSomeOtherMechanism_sentMessage() {
        let target = SentMessageTest_shared()

        object_setClass(target, SentMessageTest_shared_mock_interceptor.self)

        do {
            _ = try target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .objectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.kvo)
        }
    }

    func testFailsInCaseObjectIsAlreadyBeingInterceptedWithSomeOtherMechanism_methodInvoked() {
        let target = SentMessageTest_shared()

        object_setClass(target, SentMessageTest_shared_mock_interceptor.self)

        do {
            _ = try target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .objectMessagesAlreadyBeingIntercepted(let targetInError, let mechanism) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
            XCTAssertEqual(mechanism, RxCocoaInterceptionMechanism.kvo)
        }
    }

    func testFailsInCaseObjectIsCF_sentMessage() {
        autoreleasepool {
            let target = "\(Date())"

            do {
                _ = try target.rx.sentMessage(#selector(getter: NSString.length))
                    .toBlocking()
                    .first()

                XCTFail()
            }
            catch let e {
                guard case .cantInterceptCoreFoundationTollFreeBridgedObjects(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual((targetInError as! NSString) as String, target)
            }
        }
    }

    func testFailsInCaseObjectIsCF_methodInvoked() {
        autoreleasepool {
            let target = "\(Date())"

            do {
                _ = try target.rx.sentMessage(#selector(getter: NSString.length))
                    .toBlocking()
                    .first()

                XCTFail()
            }
            catch let e {
                guard case .cantInterceptCoreFoundationTollFreeBridgedObjects(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                    XCTFail()
                    return
                }

                XCTAssertEqual((targetInError as! NSString) as String, target)
            }
        }
    }

}

// MARK: Test interaction with KVO

extension SentMessageTest {
    func testWorksWithKVOInCaseKVORegisteredAfter_sentMessage() {
        let target = SentMessageTest_shared()

        let messages = target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
        var stages: [MessageProcessingStage] = []

        let kvo = target.rx.observe(NSArray.self, "messages")
            .subscribe(onNext: { _ in
            })

        var recordedMessages = [MethodParameters]()
        let methodObserving = messages.subscribe(onNext: { n in
            stages.append(.sentMessage)
            recordedMessages.append(n)
        })

        target.invokedMethod = {
            stages.append(.invoking)
        }

        target.justCalledBool(toSay: true)

        kvo.dispose()

        target.justCalledBool(toSay: false)

        XCTAssertEqual(stages, [.sentMessage, .invoking, .sentMessage, .invoking])
        XCTAssertEqualAnyObjectArrayOfArrays(recordedMessages, [[NSNumber(value: true)], [NSNumber(value: false)]])

        methodObserving.dispose()
    }

    func testWorksWithKVOInCaseKVORegisteredAfter_methodInvoked() {
        let target = SentMessageTest_shared()

        let messages = target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))
        var stages: [MessageProcessingStage] = []

        let kvo = target.rx.observe(NSArray.self, "messages")
            .subscribe(onNext: { _ in
            })

        var recordedMessages = [MethodParameters]()
        let methodObserving = messages.subscribe(onNext: { n in
            stages.append(.methodInvoked)
            recordedMessages.append(n)
        })

        target.invokedMethod = {
            stages.append(.invoking)
        }

        target.justCalledBool(toSay: true)

        kvo.dispose()

        target.justCalledBool(toSay: false)

        XCTAssertEqual(stages, [.invoking, .methodInvoked, .invoking, .methodInvoked])
        XCTAssertEqualAnyObjectArrayOfArrays(recordedMessages, [[NSNumber(value: true)], [NSNumber(value: false)]])
        
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

        var stages: [MessageProcessingStage] = []

        autoreleasepool {
            let target = SentMessageTest_shared()

            messages = target.rx.sentMessage(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))

            target.invokedMethod = {
                stages.append(.invoking)
            }

            target.justCalledBool(toSay: true)

            messages.subscribe(onNext: { n in
                recordedMessages.append(n)
                stages.append(.sentMessage)
                }, onCompleted: {
                    completed = true
            }).disposed(by: disposeBag)

            target.justCalledBool(toSay: true)
        }

        XCTAssertEqual(stages, [.invoking, .sentMessage, .invoking])
        XCTAssertEqualAnyObjectArrayOfArrays(recordedMessages, [[NSNumber(value: true)]])
        XCTAssertTrue(completed)
    }

    func testInvokedMethodSubjectHasPublishBehavior() {
        var messages: Observable<MethodParameters>!
        var recordedMessages = [MethodParameters]()
        var completed = false
        let disposeBag = DisposeBag()

        var stages: [MessageProcessingStage] = []

        autoreleasepool {
            let target = SentMessageTest_shared()

            messages = target.rx.methodInvoked(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)))

            target.invokedMethod = {
                stages.append(.invoking)
            }

            target.justCalledBool(toSay: true)

            messages.subscribe(onNext: { n in
                recordedMessages.append(n)
                stages.append(.methodInvoked)
                }, onCompleted: {
                    completed = true
            }).disposed(by: disposeBag)

            target.justCalledBool(toSay: true)
        }

        XCTAssertEqual(stages, [.invoking, .invoking, .methodInvoked])
        XCTAssertEqualAnyObjectArrayOfArrays(recordedMessages, [[NSNumber(value: true)]])
        XCTAssertTrue(completed)
    }

    func testDeallocSubjectHasReplayBehavior1() {
        var deallocSequence: Observable<MethodParameters>!
        autoreleasepool {
            let target = SentMessageTest_shared()

            deallocSequence = target.rx.sentMessage(NSSelectorFromString("dealloc"))
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

            deallocSequence = target.rx.deallocating
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
    func testObserve_special_class_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(NSSelectorFromString("class"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_class_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(NSSelectorFromString("class"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_forwardingTargetForSelector_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(NSSelectorFromString("forwardingTargetForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_forwardingTargetForSelector_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(NSSelectorFromString("forwardingTargetForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_methodSignatureForSelector_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(NSSelectorFromString("methodSignatureForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_methodSignatureForSelector_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(NSSelectorFromString("methodSignatureForSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_respondsToSelector_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(NSSelectorFromString("respondsToSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_special_respondsToSelector_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(NSSelectorFromString("respondsToSelector:"))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingPerformanceSensitiveMessages(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }
}

// MARK: Test return value check

extension SentMessageTest {
    func testObserve_largeStructReturnValueFails_sentMessage() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.sentMessage(#selector(SentMessageTestBase_shared.hugeResult))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingMessagesWithUnsupportedReturnType(let targetInError) = e as! RxCocoaObjCRuntimeError else {
                XCTFail()
                return
            }

            XCTAssertEqual(targetInError as? SentMessageTest_shared, target)
        }
    }

    func testObserve_largeStructReturnValueFails_methodInvoked() {
        let target = SentMessageTest_shared()

        do {
            _ = try target.rx.methodInvoked(#selector(SentMessageTestBase_shared.hugeResult))
                .toBlocking()
                .first()

            XCTFail()
        }
        catch let e {
            guard case .observingMessagesWithUnsupportedReturnType(let targetInError) = e as! RxCocoaObjCRuntimeError else {
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

        let closure: () -> Void = {  }

        let constChar = ("you better be listening" as NSString).utf8String!

        let largeStruct = some_insanely_large_struct(a: (0, 1, 2, 3, 4, 5, 6, 7), some_large_text: nil, next: nil)

        let startRuntimeState = RxObjCRuntimeState()

        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledObject(toSay:)),
                                               sendMessage: { x in NSValue(nonretainedObject: x.justCalledObject(toSay: object)) },
                                               expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledClass(toSay:)), sendMessage: { x in NSValue(nonretainedObject: x.justCalledClass(toSay: type(of: object))) }, expectedResult: NSValue(nonretainedObject: type(of: object)))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledClosure(toSay:)),
                                               sendMessage: { x in "\(String(describing: x.justCalledClosure(toSay: closure)))" },
                                               expectedResult: "\(String(describing: closure))")
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledChar(toSay:)),
                                               sendMessage: { x in x.justCalledChar(toSay: 3)},
                                               expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledShort(toSay:)),
                                               sendMessage: { x in x.justCalledShort(toSay: 4) },
                                               expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledInt(toSay:)),
                                               sendMessage: { x in x.justCalledInt(toSay: 5) },
                                               expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledLong(toSay:)),
                                               sendMessage: { x in x.justCalledLong(toSay: 6) },
                                               expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledLongLong(toSay:)),
                                               sendMessage: { x in x.justCalledLongLong(toSay: 7) },
                                               expectedResult: 7)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledUnsignedChar(toSay:)),
                                               sendMessage: { x in x.justCalledUnsignedChar(toSay: 8) },
                                               expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledUnsignedShort(toSay:)),
                                               sendMessage: { x in x.justCalledUnsignedShort(toSay: 9) },
                                               expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledUnsignedInt(toSay:)),
                                               sendMessage: { x in x.justCalledUnsignedInt(toSay: 10) },
                                               expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledUnsignedLong(toSay:)),
                                               sendMessage: { x in x.justCalledUnsignedLong(toSay: 11) },
                                               expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledUnsignedLongLong(toSay:)),
                                               sendMessage: { x in x.justCalledUnsignedLongLong(toSay: 12) },
                                               expectedResult: 12)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledFloat(toSay:)),
                                               sendMessage: { x in x.justCalledFloat(toSay: 13) },
                                               expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledDouble(toSay:)),
                                               sendMessage: { x in x.justCalledDouble(toSay: 13) },
                                               expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledBool(toSay:)),
                                               sendMessage: { x in x.justCalledBool(toSay: true) },
                                               expectedResult: true)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledConstChar(toSay:)),
                                               sendMessage: { x in x.justCalledConstChar(toSay: constChar) },
                                               expectedResult: constChar)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.justCalledLarge(toSay:)),
                                               sendMessage: { x in x.justCalledLarge(toSay: largeStruct) },
                                               expectedResult: 28)

        let middleRuntimeState = RxObjCRuntimeState()

        let middleChanges = RxObjCRuntimeChange.changes(dynamicSubclasses: 1, swizzledForwardClasses: 1, methodsForwarded: 18)
        middleRuntimeState.assertAfterThisMoment(startRuntimeState, changed:middleChanges)

        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledObject(toSay:)), sendMessage: { x in x.voidJustCalledObject(toSay: object); return NSValue(nonretainedObject: object)  }, expectedResult: NSValue(nonretainedObject: object))
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledClosure(toSay:)),
                                               sendMessage: { x in x.voidJustCalledClosure(toSay: closure); return "\(String(describing: closure))" },
                                               expectedResult: "\(String(describing: closure))")
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledChar(toSay:)),
                                               sendMessage: { x in x.voidJustCalledChar(toSay: 3); return 3 },
                                               expectedResult: 3)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledShort(toSay:)),
                                               sendMessage: { x in x.voidJustCalledShort(toSay: 4); return 4 },
                                               expectedResult: 4)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledInt(toSay:)),
                                               sendMessage: { x in x.voidJustCalledInt(toSay: 5); return 5 },
                                               expectedResult: 5)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledLong(toSay:)),
                                               sendMessage: { x in x.voidJustCalledLong(toSay: 6); return 6 },
                                               expectedResult: 6)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledUnsignedChar(toSay:)),
                                               sendMessage: { x in x.voidJustCalledUnsignedChar(toSay: 8); return 8 },
                                               expectedResult: 8)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledUnsignedShort(toSay:)),
                                               sendMessage: { x in x.voidJustCalledUnsignedShort(toSay: 9); return 9 },
                                               expectedResult: 9)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledUnsignedInt(toSay:)),
                                               sendMessage: { x in x.voidJustCalledUnsignedInt(toSay: 10); return 10 },
                                               expectedResult: 10)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledUnsignedLong(toSay:)),
                                               sendMessage: { x in x.voidJustCalledUnsignedLong(toSay: 11); return 11 },
                                               expectedResult: 11)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledDouble(toSay:)),
                                               sendMessage: { x in x.voidJustCalledDouble(toSay: 13); return 13 },
                                               expectedResult: 13)
        _testMessageRecordedAndAllCallsAreMade(#selector(SentMessageTestBase_shared.voidJustCalledFloat(toSay:)), sendMessage: { x in x.voidJustCalledFloat(toSay: 13); return 13 }, expectedResult: 13)

        let endRuntimeState = RxObjCRuntimeState()

        endRuntimeState.assertAfterThisMoment(middleRuntimeState, changed: RxObjCRuntimeChange.changes(methodsSwizzled: 12))

    }

    func _testMessageRecordedAndAllCallsAreMade<Result: Equatable>(_ selector: Selector, sendMessage: @escaping (SentMessageTest_all_supported_types) -> Result, expectedResult: Result) {
        _testMessageRecordedAndAllCallsAreMade(selector, sendMessage: sendMessage, expectedResult: expectedResult) { target, selector in
            return ObservedSequence.sentMessage(target.rx.sentMessage(selector))
        }
        _testMessageRecordedAndAllCallsAreMade(selector, sendMessage: sendMessage, expectedResult: expectedResult) { target, selector in
            return ObservedSequence.methodInvoked(target.rx.methodInvoked(selector))
        }
    }

    func _testMessageRecordedAndAllCallsAreMade<Result: Equatable>(_ selector: Selector, sendMessage: @escaping (SentMessageTest_all_supported_types) -> Result, expectedResult: Result, methodSelector: @escaping (SentMessageTest_all_supported_types, Selector) -> ObservedSequence) {
        var observedMessages = [[Any]]()
        var receivedDerivedClassMessage = [[Any]]()
        var receivedBaseClassMessage = [[Any]]()
        var completed = false

        var result: Result! = nil

        var stages: [MessageProcessingStage] = []
        
        let action: () -> Disposable = { () -> Disposable in
            let target = SentMessageTest_all_supported_types()

            let observedSequence = methodSelector(target, selector)

            let d = observedSequence.sequence.subscribe(onNext: { n in
                    stages.append(observedSequence.stage)
                    observedMessages.append(n)
                }, onError: { e in
                    XCTFail("Errors out \(e)")
                }, onCompleted: {
                    completed = true
                })

            target.invokedMethod = {
                stages.append(.invoking)
            }
            
            result = sendMessage(target)

            receivedDerivedClassMessage = target.messages.map { $0.values }
            receivedBaseClassMessage = target.baseMessages.map { $0.values }

            return d
        }

        action().dispose()

        XCTAssertEqual(stages, stages.sorted(by: { $0.rawValue < $1.rawValue }))
        XCTAssertTrue(stages.count > 0)
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
    func ensureGlobalRuntimeChangesAreCached<T: SentMessageTestClassCreationProtocol & NSObjectProtocol>(
        _ createIt: @escaping () -> T,
        observeIt: @escaping (T) -> [ObservedSequence],
        objectActingClassChange: [ObjectRuntimeChange],
        objectRealClassChange: [ObjectRuntimeChange],
        runtimeChange: RxObjCRuntimeChange,
        useIt: @escaping (T) -> [[MethodParameters]]
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

    func _ensureGlobalRuntimeChangesAreCached<T: SentMessageTestClassCreationProtocol & NSObjectProtocol> (
        _ createIt: () -> T,
        observeIt: (T) -> [ObservedSequence],
        expectedActingClassChanges: [ObjectRuntimeChange],
        expectedRealClassChanges: [ObjectRuntimeChange],
        runtimeChange: RxObjCRuntimeChange,
        useIt: (T) -> [[MethodParameters]]
        ) {

        let originalRuntimeState = RxObjCRuntimeState()

        var createdObject: T! = nil
        var disposables = [Disposable]()

        var nCompleted = 0
        var recordedParameters = [[MethodParameters]]()
        var observables: [ObservedSequence] = []

        autoreleasepool {
            createdObject = createIt()
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

        var messageProcessingStage: [MessageProcessingStage] = []
        autoreleasepool {
            var i = 0

            for o in observables {
                let index = i
                i += 1
                recordedParameters.append([])
                _ = o.sequence.subscribe(onNext: { n in
                        messageProcessingStage.append(o.stage)
                        recordedParameters[index].append(n)
                    }, onError: { e in
                        XCTFail("Error happened \(e)")
                    }, onCompleted: { () -> Void in
                        nCompleted += 1
                    })
            }
        }

        var invokedCount = 0
        createdObject.invokedMethod = {
            messageProcessingStage.append(.invoking)
            invokedCount = invokedCount + 1
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
            createdObject = nil
        }

        // ensure all observables are completed on object dispose
        XCTAssertTrue(nCompleted == observables.count)

        // expected parameters should be sorted
        XCTAssertEqual(messageProcessingStage, messageProcessingStage.sorted(by: { $0.rawValue < $1.rawValue }))
        XCTAssertEqual(messageProcessingStage.count, observables.count + invokedCount)

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
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {

    }

    func createKVODynamicSubclassed<T: SentMessageTestClassCreationProtocol & NSObjectProtocol>(_ type: T.Type = T.self) -> () -> (T, [Disposable]) {
        return {
            let t = T.createInstance()
            //let disposable = (t as! NSObject).rx.observe(NSArray.self, "messages").publish().connect()
            (t as! NSObject).addObserver(self, forKeyPath: "messages", options: [], context: nil)
            return (t, [Disposables.create { (t as! NSObject).removeObserver(self, forKeyPath: "messages") }])
        }
    }

    func createNormalInstance<T: SentMessageTestClassCreationProtocol & NSObjectProtocol>(_ type: T.Type = T.self) -> () -> T {
        return {
            return T.createInstance()
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
