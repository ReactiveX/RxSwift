//
//  UINavigationController+Rx.swift
//  RxCocoa
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

extension Reactive where Base: UINavigationController {
    public typealias ShowEvent = (viewController: UIViewController, animated: Bool)

    /// Reactive wrapper for `delegate`.
    ///
    /// For more information take a look at `DelegateProxyType` protocol documentation.
    public var delegate: DelegateProxy<UINavigationController, UINavigationControllerDelegate> {
        RxNavigationControllerDelegateProxy.proxy(for: base)
    }
    
    /// Installs delegate as forwarding delegate on `delegate`.
    /// Delegate won't be retained.
    ///
    /// It enables using normal delegate mechanism with reactive delegate mechanism.
    ///
    /// - parameter delegate: Delegate object.
    /// - returns: Disposable object that can be used to unbind the delegate.
    public func setDelegate(_ delegate: UINavigationControllerDelegate)
        -> Disposable {
        return RxNavigationControllerDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
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
