//
//  UIActionSheet+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension UIActionSheet {
    
    public var rx_delegate: DelegateProxy {
        return proxyForObject(self) as RxActionSheetDelegateProxy
    }
    
    public var rx_clickedButtonAtIndex: Observable<Int> {
        return rx_delegate.observe("actionSheet:clickedButtonAtIndex:")
            >- map { a in
                return a[1] as! Int
            }
    }
    
    public var rx_willDismissWithButtonIndex: Observable<Int> {
        return rx_delegate.observe("actionSheet:willDismissWithButtonIndex:")
            >- map { a in
                return a[1] as! Int
            }
    }
    
    public var rx_didDismissWithButtonIndex: Observable<Int> {
        return rx_delegate.observe("actionSheet:didDismissWithButtonIndex:")
            >- map { a in
                return a[1] as! Int
            }
    }
}