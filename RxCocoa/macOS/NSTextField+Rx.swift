//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

/// Delegate proxy for `NSTextField`.
///
/// For more information take a look at `DelegateProxyType`.
open class RxTextFieldDelegateProxy
    : DelegateProxy<NSTextField, NSTextFieldDelegate>
    , DelegateProxyType 
    , NSTextFieldDelegate {

    /// Typed parent object.
    public weak private(set) var textField: NSTextField?

    /// Initializes `RxTextFieldDelegateProxy`
    ///
    /// - parameter textField: Parent object for delegate proxy.
    init(textField: NSTextField) {
        self.textField = textField
        super.init(parentObject: textField, delegateProxy: RxTextFieldDelegateProxy.self)
    }

    public static func registerKnownImplementations() {
        self.register { RxTextFieldDelegateProxy(textField: $0) }
    }

    fileprivate let textSubject = PublishSubject<String?>()

    // MARK: Delegate methods

    open override func controlTextDidChange(_ notification: Notification) {
        let textField: NSTextField = castOrFatalError(notification.object)
        let nextValue = textField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange?(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> NSTextFieldDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: NSTextFieldDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
    
}

extension Reactive where Base: NSTextField {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<NSTextField, NSTextFieldDelegate> {
        return RxTextFieldDelegateProxy.proxy(for: base)
    }
    
    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
        let delegate = RxTextFieldDelegateProxy.proxy(for: base)
        
        let source = Observable.deferred { [weak textField = self.base] in
            delegate.textSubject.startWith(textField?.stringValue)
        }.takeUntil(deallocated)

        let observer = Binder(base) { (control, value: String?) in
            control.stringValue = value ?? ""
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
    
}

#endif
