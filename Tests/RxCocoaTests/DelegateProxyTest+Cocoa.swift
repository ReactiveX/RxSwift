//
//  DelegateProxyTest+Cocoa.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Cocoa
@testable import RxCocoa
@testable import RxSwift
import XCTest

// MARK: Tests

extension DelegateProxyTest {
    func test_NSTextFieldDelegateExtension() {
        performDelegateTest(NSTextFieldSubclass(frame: CGRect.zero))
    }

    func test_NSComboBoxDelegateExtension() {
        performDelegateTest(NSComboBoxSubclass(frame: CGRect.zero))
    }
}

// MARK: Mocks

class ExtendNSTextFieldDelegateProxy
    : RxTextFieldDelegateProxy
    , TestDelegateProtocol {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}

final class NSTextFieldSubclass
    : NSTextField
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
        return ExtendNSTextFieldDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxTextFieldDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}


class ExtendNSComboBoxDelegateProxy
    : RxComboBoxDelegateProxy
, TestDelegateProtocol {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}

final class NSComboBoxSubclass
    : NSComboBox
, TestDelegateControl {
    override func createComboBoxRxDelegateProxy() -> RxComboBoxDelegateProxy {
        return ExtendNSComboBoxDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        let r = self.rx
        return r.delegateProxy
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxComboBoxDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
