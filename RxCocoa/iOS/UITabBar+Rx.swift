//
//  UITabBar+Rx.swift
//  RxCocoa
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

/**
 iOS only
 */
#if os(iOS)
extension Reactive where Base: UITabBar {

    /// Reactive wrapper for `delegate` message `tabBar:willBeginCustomizingItems:`.
    public var willBeginCustomizing: ControlEvent<[UITabBarItem]> {
        
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willBeginCustomizing:)))
            .map { a in
                return try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar:didBeginCustomizingItems:`.
    public var didBeginCustomizing: ControlEvent<[UITabBarItem]> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didBeginCustomizing:)))
            .map { a in
                return try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar:willEndCustomizingItems:changed:`.
    public var willEndCustomizing: ControlEvent<([UITabBarItem], Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willEndCustomizing:changed:)))
            .map { (a: [Any]) -> (([UITabBarItem], Bool)) in
                let items = try castOrThrow([UITabBarItem].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar:didEndCustomizingItems:changed:`.
    public var didEndCustomizing: ControlEvent<([UITabBarItem], Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didEndCustomizing:changed:)))
            .map { (a: [Any]) -> (([UITabBarItem], Bool)) in
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
    
    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createRxDelegateProxy() -> RxTabBarDelegateProxy {
        return RxTabBarDelegateProxy(parentObject: self)
    }

}

extension Reactive where Base: UITabBar {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxTabBarDelegateProxy.proxyForObject(base)
    }

    /// Reactive wrapper for `delegate` message `tabBar:didSelectItem:`.
    public var didSelectItem: ControlEvent<UITabBarItem> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didSelect:)))
            .map { a in
                return try castOrThrow(UITabBarItem.self, a[1])
            }

        return ControlEvent(events: source)
    }

}

#endif
