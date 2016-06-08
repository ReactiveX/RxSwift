//
//  UITabBar+Rx.swift
//  Rx
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

/**
 iOS only
 */
#if os(iOS)
extension UITabBar {

    /**
     Reactive wrapper for `delegate` message `tabBar:willBeginCustomizingItems:`.
    */
    public var rx_willBeginCustomizing: ControlEvent<[UITabBarItem]> {
        let source = rx_delegate.observe(#selector(UITabBarDelegate.tabBar(_:willBeginCustomizingItems:)))
            .map { a in
                return try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tabBar:didBeginCustomizingItems:`.
    */
    public var rx_didBeginCustomizing: ControlEvent<[UITabBarItem]> {
        let source = rx_delegate.observe(#selector(UITabBarDelegate.tabBar(_:didBeginCustomizingItems:)))
            .map { a in
                return try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tabBar:willEndCustomizingItems:changed:`.
    */
    public var rx_willEndCustomizing: ControlEvent<(items: [UITabBarItem], changed: Bool)> {
        let source = rx_delegate.observe(#selector(UITabBarDelegate.tabBar(_:willEndCustomizingItems:changed:)))
            .map { (a: [AnyObject]) -> (([UITabBarItem], Bool)) in
                let items = try castOrThrow([UITabBarItem].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return ControlEvent(events: source)
    }

    /**
     Reactive wrapper for `delegate` message `tabBar:didEndCustomizingItems:changed:`.
    */
    public var rx_didEndCustomizing: ControlEvent<(items: [UITabBarItem], changed: Bool)> {
        let source = rx_delegate.observe(#selector(UITabBarDelegate.tabBar(_:didEndCustomizingItems:changed:)))
            .map { (a: [AnyObject]) -> (([UITabBarItem], Bool)) in
                let items = try castOrThrow([UITabBarItem].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return ControlEvent(events: source)
    }

}
#endif

/**
 iOS and tvOS
 */
extension UITabBar {
    
    /**
     Factory method that enables subclasses to implement their own `rx_delegate`.

     - returns: Instance of delegate proxy that wraps `delegate`.
     */
    public func rx_createDelegateProxy() -> RxTabBarDelegateProxy {
        return RxTabBarDelegateProxy(parentObject: self)
    }

    /**
     Reactive wrapper for `delegate`.

     For more information take a look at `DelegateProxyType` protocol documentation.
    */
    public var rx_delegate: DelegateProxy {
        return RxTabBarDelegateProxy.proxyForObject(self)
    }

    /**
     Reactive wrapper for `delegate` message `tabBar:didSelectItem:`.
    */
    public var rx_didSelectItem: ControlEvent<UITabBarItem> {
        let source = rx_delegate.observe(#selector(UITabBarDelegate.tabBar(_:didSelectItem:)))
            .map { a in
                return try castOrThrow(UITabBarItem.self, a[1])
            }

        return ControlEvent(events: source)
    }

}

#endif
