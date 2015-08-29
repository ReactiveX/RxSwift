//
//  UIAlertView+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension UIAlertView {
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxAlertViewDelegateProxy
    }
    
    public var rx_clickedButtonAtIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:clickedButtonAtIndex:")
            .map { a in
                return a[1] as! Int
            }

        return ControlEvent(source: source)
    }
    
    public var rx_willDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:willDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(source: source)
    }
    
    public var rx_didDismissWithButtonIndex: ControlEvent<Int> {
        let source = rx_delegate.observe("alertView:didDismissWithButtonIndex:")
            .map { a in
                return a[1] as! Int
            }
        
        return ControlEvent(source: source)
    }
}
