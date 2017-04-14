//
//  UINavigationController+Rx.swift
//  RxCocoa
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UINavigationController {
    /// Factory method that enables subclasses to implement their own `delegate`.
    ///
    /// - returns: Instance of delegate proxy that wraps `delegate`.
    public func createRxDelegateProxy() -> RxNavigationControllerDelegateProxy {
        return RxNavigationControllerDelegateProxy(parentObject: self)
    }
}

extension Reactive where Base: UINavigationController {
    public typealias ShowEvent = (viewController: UIViewController, animated: Bool)

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy {
        return RxNavigationControllerDelegateProxy.proxyForObject(base)
    }

    /// Reactive wrapper for delegate method `navigationController(:willShow:animated:)`.
    public var willShow: ControlEvent<ShowEvent> {
        let source: Observable<ShowEvent> = delegate
            .methodInvoked(#selector(UINavigationControllerDelegate.navigationController(_:willShow:animated:)))
            .map { arg in
                let viewController = try castOrThrow(UIViewController.self, arg[1])
                let animated = try castOrThrow(Bool.self, arg[2])
                return (viewController, animated)
        }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `navigationController(:didShow:animated:)`.
    public var didShow: ControlEvent<ShowEvent> {
        let source: Observable<ShowEvent> = delegate
            .methodInvoked(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
            .map { arg in
                let viewController = try castOrThrow(UIViewController.self, arg[1])
                let animated = try castOrThrow(Bool.self, arg[2])
                return (viewController, animated)
        }
        return ControlEvent(events: source)
    }
}

#endif
