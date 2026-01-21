//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
import RxSwift

/// Delegate proxy for `NSTextField`.
///
/// For more information take a look at `DelegateProxyType`.
open class RxTextFieldDelegateProxy:
    DelegateProxy<NSTextField, NSTextFieldDelegate>,
    DelegateProxyType,
    NSTextFieldDelegate
{
    /// Typed parent object.
    public private(set) weak var textField: NSTextField?

    /// Initializes `RxTextFieldDelegateProxy`
    ///
    /// - parameter textField: Parent object for delegate proxy.
    init(textField: NSTextField) {
        self.textField = textField
        super.init(parentObject: textField, delegateProxy: RxTextFieldDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        register { RxTextFieldDelegateProxy(textField: $0) }
    }

    fileprivate let textSubject = PublishSubject<String?>()

    // MARK: Delegate methods

    open func controlTextDidChange(_ notification: Notification) {
        let textField: NSTextField = castOrFatalError(notification.object)
        let nextValue = textField.stringValue
        textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange?(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> NSTextFieldDelegate? {
        object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: NSTextFieldDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
}

public extension Reactive where Base: NSTextField {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<NSTextField, NSTextFieldDelegate> {
        RxTextFieldDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `text` property.
    var text: ControlProperty<String?> {
        let delegate = RxTextFieldDelegateProxy.proxy(for: base)

        let source = Observable.deferred { [weak textField = self.base] in
            delegate.textSubject.startWith(textField?.stringValue)
        }.take(until: deallocated)

        let observer = Binder(base) { (control, value: String?) in
            control.stringValue = value ?? ""
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
}

#endif
