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
public class RxTextFieldDelegateProxy
    : DelegateProxy
    , NSTextFieldDelegate
    , DelegateProxyType {
    
    public static var factory = DelegateProxyFactory { (parentObject: NSTextField) in
        RxTextFieldDelegateProxy(parentObject: parentObject)
    }

    fileprivate let textSubject = PublishSubject<String?>()

    /// Typed parent object.
    public weak private(set) var textField: NSTextField?

    /// Initializes `RxTextFieldDelegateProxy`
    ///
    /// - parameter parentObject: Parent object for delegate proxy.
    public required init(parentObject: AnyObject) {
        self.textField = castOrFatalError(parentObject)
        super.init(parentObject: parentObject)
    }

    // MARK: Delegate methods

    public override func controlTextDidChange(_ notification: Notification) {
        let textField: NSTextField = castOrFatalError(notification.object)
        let nextValue = textField.stringValue
        self.textSubject.on(.next(nextValue))
        _forwardToDelegate?.controlTextDidChange(notification)
    }

    // MARK: Delegate proxy methods

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let textField: NSTextField = castOrFatalError(object)
        return textField.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let textField: NSTextField = castOrFatalError(object)
        textField.delegate = castOptionalOrFatalError(delegate)
    }
    
}

extension Reactive where Base: NSTextField {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }
    
    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
        let delegate = RxTextFieldDelegateProxy.proxyForObject(base)
        
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
