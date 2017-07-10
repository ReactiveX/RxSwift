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
    /// Reactive wrapper for `text` property
    public var text: ControlProperty<String?> {
        return value
    }

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(base)
    }
    
    /// Reactive wrapper for `text` property.
    public var value: ControlProperty<String?> {
        let source: Observable<String?> = Observable.deferred { [weak textField = self.base as UITextField] () -> Observable<String?> in
            let text = textField?.text
            
            return (textField?.rx.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidEndEditing(_:))) ?? Observable.empty())
                .map { a in
                    return a[1] as? String
                }
                .startWith(text)
        }
        
        let bindingObserver = UIBindingObserver(UIElement: self.base) { (textField, text: String?) in
            if textField.text != text {
                textField.text = text
            }
        }
        
        return ControlProperty(values: source, valueSink: bindingObserver)
    }
    
    /// Reactive wrapper for `delegate` message.
    public var didBeginEditing: ControlEvent<()> {
        return ControlEvent<()>(events:
            self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidBeginEditing(_:)))
            .map { a in
                return ()
        })
    }
    
    /// Reactive wrapper for `delegate` message.
    public var didEndEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldDidEndEditing(_:)))
            .map { a in
                return ()
        })
    }
    

    /// Reactive wrapper for `delegate` message.
    public var shouldBeginEditing: ControlEvent<()> {
        return ControlEvent<()>(events:
            self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldShouldBeginEditing(_:)))
            .map { a in
                return ()
        })
    }
    
    /// Reactive wrapper for `delegate` message.
    public var shouldEndEditing: ControlEvent<()> {
        return ControlEvent<()>(events: self.delegate.methodInvoked(#selector(UITextFieldDelegate.textFieldShouldEndEditing(_:)))
            .map { a in
                return ()
        })
    }

}
    
#endif
