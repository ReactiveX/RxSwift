//
//  UITabBarController+Rx.swift
//  RxCocoa
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import UIKit

/**
 iOS only
 */
#if os(iOS)
public extension Reactive where Base: UITabBarController {
    /// Reactive wrapper for `delegate` message `tabBarController:willBeginCustomizing:`.
    var willBeginCustomizing: ControlEvent<[UIViewController]> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:willBeginCustomizing:)))
            .map { a in
                try castOrThrow([UIViewController].self, a[1])
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBarController:willEndCustomizing:changed:`.
    var willEndCustomizing: ControlEvent<(viewControllers: [UIViewController], changed: Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:willEndCustomizing:changed:)))
            .map { (a: [Any]) -> (viewControllers: [UIViewController], changed: Bool) in
                let viewControllers = try castOrThrow([UIViewController].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (viewControllers, changed)
            }

        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `delegate` message `tabBarController:didEndCustomizing:changed:`.
    var didEndCustomizing: ControlEvent<(viewControllers: [UIViewController], changed: Bool)> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:didEndCustomizing:changed:)))
            .map { (a: [Any]) -> (viewControllers: [UIViewController], changed: Bool) in
                let viewControllers = try castOrThrow([UIViewController].self, a[1])
                let changed = try castOrThrow(Bool.self, a[2])
                return (viewControllers, changed)
            }

        return ControlEvent(events: source)
    }
}
#endif

/**
 iOS and tvOS
 */

public extension Reactive where Base: UITabBarController {
    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    var delegate: DelegateProxy<UITabBarController, UITabBarControllerDelegate> {
        RxTabBarControllerDelegateProxy.proxy(for: base)
    }

    /// Reactive wrapper for `delegate` message `tabBarController:didSelect:`.
    var didSelect: ControlEvent<UIViewController> {
        let source = delegate.methodInvoked(#selector(UITabBarControllerDelegate.tabBarController(_:didSelect:)))
            .map { a in
                try castOrThrow(UIViewController.self, a[1])
            }

        return ControlEvent(events: source)
    }
}

#endif
