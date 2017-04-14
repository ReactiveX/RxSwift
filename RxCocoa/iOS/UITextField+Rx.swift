//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UITextField {

    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createRxDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(parentObject: self)
    }

}

extension Reactive where Base: UITextField {

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }

    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
        return value
    }
    
    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        return UIControl.rx.value(
            base,
            getter: { textField in
                textField.text
            }, setter: { textField, value in
                // This check is important because setting text value always clears control state
                // including marked text selection which is imporant for proper input 
                // when IME input method is used.
                if textField.text != value {
                    textField.text = value
                }
            }
        )
    }

    /// Reactive wrapper for delegate method `textFieldShouldClear`
    public var shouldClear: ControlEvent<Void> {
        let source = RxTextFieldDelegateProxy.proxyForObject(base).shouldClearPublishSubject.map { _ in return }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `textFieldShouldReturn`
    public var shouldReturn: ControlEvent<Void> {
        let source = RxTextFieldDelegateProxy.proxyForObject(base).shouldReturnPublishSubject.map { _ in return }
        return ControlEvent(events: source)
    }

    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    public func setDelegate(_ delegate: UITextFieldDelegate)
        -> Disposable {
            return RxTextFieldDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

#endif
