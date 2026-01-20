//
//  UITabBar+Rx.swift
//  RxCocoa
//
//  Created by Jesse Farless on 5/13/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

/**
 iOS only
 */
#if os(iOS)
public extension Reactive where Base: UITabBar {
    /// Reactive wrapper for `delegate` message `tabBar(_:willBeginCustomizing:)`.
    var willBeginCustomizing: ControlEvent<[UITabBarItem]> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willBeginCustomizing:)))
            .map { a in
                try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didBeginCustomizing:)`.
    var didBeginCustomizing: ControlEvent<[UITabBarItem]> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didBeginCustomizing:)))
            .map { a in
                try castOrThrow([UITabBarItem].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:willEndCustomizing:changed:)`.
    var willEndCustomizing: ControlEvent<([UITabBarItem], Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:willEndCustomizing:changed:)))
            .map { (a: [Any]) -> (([UITabBarItem], Bool)) in
                let items = try castOrThrow([UITabBarItem].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (items, changed)
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didEndCustomizing:changed:)`.
    var didEndCustomizing: ControlEvent<([UITabBarItem], Bool)> {
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

public extension Reactive where Base: UITabBar {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<UITabBar, UITabBarDelegate> {
        RxTabBarDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `delegate` message `tabBar(_:didSelect:)`.
    var didSelectItem: ControlEvent<UITabBarItem> {
        let source = delegate.methodInvoked(#selector(UITabBarDelegate.tabBar(_:didSelect:)))
            .map { a in
                try castOrThrow(UITabBarItem.self, a[1])
            }

        return ControlEvent(events: source)
    }
}

#endif
