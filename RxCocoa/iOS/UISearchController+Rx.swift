//
//  UISearchController+Rx.swift
//  Rx
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
    import Foundation
    
#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit
    
extension UISearchController {
    /**
     Reactive wrapper for `delegate`.
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var rx_delegate: DelegateProxy {
        return proxyForObject(RxSearchControllerDelegateProxy.self, self)
    }
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_didDismiss: Observable<Void> {
        return rx_delegate
            .observe(selector: #selector(UISearchControllerDelegate.didDismiss(_:)))
            .map {_ in}
    }
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_didPresent: Observable<Void> {
        return rx_delegate
            .observe(selector: #selector(UISearchControllerDelegate.didPresent(_:)))
            .map {_ in}
    }
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_present: Observable<Void> {
        return rx_delegate
            .observe(selector: #selector(UISearchControllerDelegate.present(_:)))
            .map {_ in}
    }
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_willDismiss: Observable<Void> {
        return rx_delegate
            .observe(selector: #selector(UISearchControllerDelegate.willDismiss(_:)))
            .map {_ in}
    }
    /**
     Reactive wrapper for `delegate` message.
     */
    public var rx_willPresent: Observable<Void> {
        return rx_delegate
            .observe(selector: #selector(UISearchControllerDelegate.willPresent(_:)))
            .map {_ in}
    }
    
}
    
#endif
