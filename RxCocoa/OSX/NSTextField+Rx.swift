//
//  NSTextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 5/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
import RxSwift
#endif

extension NSTextField : RxTextInput {

    /**
    Factory method that enables subclasses to implement their own `rx_delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxTextFieldDelegateProxy {
        return RxTextFieldDelegateProxy(parentObject: self)
    }

    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return RxTextFieldDelegateProxy.proxyForObject(self)
    }
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        let delegate = RxTextFieldDelegateProxy.proxyForObject(self)
        
        let source = Observable.deferred { [weak self] in
            delegate.textSubject.startWith(self?.stringValue ?? "")
        }.takeUntil(rx_deallocated)

        let observer = UIBindingObserver(UIElement: self) { control, value in
            control.stringValue = value
        }

        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
    
}
