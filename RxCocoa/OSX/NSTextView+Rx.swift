//
//  NSTextView+Rx.swift
//  Rx
//
//  Created by Junior B. on 21/06/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Cocoa
#if !RX_NO_MODULE
    import RxSwift
#endif

extension NSTextView {
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.
     
     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxTextViewDelegateProxy {
        return RxTextViewDelegateProxy(parentObject: self)
    }
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_delegate: DelegateProxy {
        return RxTextViewDelegateProxy.proxyForObject(self)
    }
    
    /**
     Reactive wrapper for `attributedString` property.
     */
    public var rx_textStorage: ControlProperty<NSAttributedString> {
        let delegate = RxTextViewDelegateProxy.proxyForObject(self)
        
        let source = Observable.deferred { [weak self] in
            delegate.textSubject.startWith(self?.textStorage ?? NSTextStorage())
            }.takeUntil(rx_deallocated)
        
        let observer = UIBindingObserver(UIElement: self) { control, value in
            control.textStorage?.setAttributedString(value)
        }
        
        return ControlProperty(values: source, valueSink: observer.asObserver())
    }
}