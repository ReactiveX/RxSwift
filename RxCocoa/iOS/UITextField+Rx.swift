//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
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
    
    /// Reactive wrapper for `text` property.
    public var text: ControlProperty<String?> {
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

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(self.base)
    }

    /// Reactive wrapper for `delegate` message.    
    public var shouldReturn: ControlEvent<Void> {
        let source = delegate.rx.methodInvoked(#selector(UITextFieldDelegate.textFieldShouldReturn(_:)))
            .map { _ in }

        return ControlEvent(events: source)
    }

}

#endif
