//
//  RxTextFieldDelegateProxy.swift
//  RxCocoa
//
//  Created by Kevin Beaulieu on 1/27/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
import RxSwift

extension UITextField: HasDelegate {
    public typealias Delegate = UITextFieldDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxTextFieldDelegateProxy
    : DelegateProxy<UITextField, UITextFieldDelegate>
    , DelegateProxyType
    , UITextFieldDelegate {

    /// Typed parent object.
    public weak private(set) var textField: UITextField?

    /// - parameter textField: Parent object for delegate proxy.
    public init(textField: UITextField) {
        self.textField = textField
        super.init(parentObject: textField, delegateProxy: RxTextFieldDelegateProxy.self)
    }

    /// Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTextFieldDelegateProxy(textField: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: UITextField) -> UITextFieldDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: UITextFieldDelegate?, to object: UITextField) {
        object.delegate = delegate
    }
}

#endif
