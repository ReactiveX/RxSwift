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

    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxTextFieldDelegateProxy.self)
    }

    fileprivate let textSubject = PublishSubject<String?>()

    /// Typed parent object.
    public weak private(set) var textField: NSTextField?

    /// Initializes `RxTextFieldDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: ParentObject) {
        self.textField = parentObject
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate methods

    open override func controlTextDidChange(_ notification: Notification) {
        let textField: NSTextField = castOrFatalError(notification.object)
        let nextValue = textField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: ParentObject) -> NSTextFieldDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: NSTextFieldDelegate?, toObject object: ParentObject) {
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

        let observer = UIBindingObserver(UIElement: base) { (control, value: String?) in
            control.stringValue = value ?? ""
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
    
}

#endif
