//
//  DelegateProxyTest+Cocoa.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
@testable import RxCocoa
@testable import RxSwift
import XCTest

// MARK: Protocols

@objc protocol NSTextFieldDelegateSubclass
    : NSTextFieldDelegate
    , TestDelegateProtocol {
}

// MARK: Tests

extension DelegateProxyTest {
    func test_NSTextFieldDelegateExtension() {
        performDelegateTest(NSTextFieldSubclass(frame: CGRect.zero))
    }
}

// MARK: Mocks

class ExtendNSTextFieldDelegateProxy
    : RxTextFieldDelegateProxy
    , NSTextFieldDelegateSubclass {
    weak private(set) var etf: NSTextFieldSubclass?

    required init(parentObject: AnyObject) {
        self.etf = (parentObject as! NSTextFieldSubclass)
        super.init(parentObject: parentObject)
    }
}

class NSTextFieldSubclass
    : NSTextField
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
        return ExtendNSTextFieldDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! NSTextFieldDelegateSubclass).testEventHappened?(value)
    }

    var testSentMessage: Observable<Int> {
        return rx.delegate
            .sentMessage(#selector(NSTextFieldDelegateSubclass.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).intValue }
    }

    var testMethodInvoked: Observable<Int> {
        return rx.delegate
            .methodInvoked(#selector(NSTextFieldDelegateSubclass.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).intValue }
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxTextFieldDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
