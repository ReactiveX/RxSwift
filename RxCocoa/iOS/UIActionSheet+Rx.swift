//
//  UIActionSheet+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension UIActionSheet {
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxActionSheetDelegateProxy
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_clickedButtonAtIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("actionSheet:clickedButtonAtIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(source: source)
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_willDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("actionSheet:willDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(source: source)
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    public var rx_didDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("actionSheet:didDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(source: source)
    }
}

#endif
