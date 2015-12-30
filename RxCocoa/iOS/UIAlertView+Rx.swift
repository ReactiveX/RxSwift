//
//  UIAlertView+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIAlertView {
    
    /**
    Reactive wrapper for `delegate`.
    
    For more information take a look at `DelegateProxyType` protocol documentation.
    */
    @available(*, deprecated=2.0.0, message="This class is deprecated by Apple. Removing official support.")
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxAlertViewDelegateProxy.self, self)
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    @available(*, deprecated=2.0.0, message="This class is deprecated by Apple. Removing official support.")
    public var rx_clickedButtonAtIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:clickedButtonAtIndex:")
            .map { a in
                return a[1] as! Int
            }

        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    @available(*, deprecated=2.0.0, message="This class is deprecated by Apple. Removing official support.")
    public var rx_willDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:willDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(events: source)
    }
    
    /**
    Reactive wrapper for `delegate` message.
    */
    @available(*, deprecated=2.0.0, message="This class is deprecated by Apple. Removing official support.")
    public var rx_didDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:didDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(events: source)
    }
}

#endif
