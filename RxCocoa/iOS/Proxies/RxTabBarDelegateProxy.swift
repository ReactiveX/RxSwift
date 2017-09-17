//
//  RxTabBarDelegateProxy.swift
//  RxCocoa
//
//  Created by Jesse Farless on 5/14/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

/// For more information take a look at `DelegateProxyType`.
open class RxTabBarDelegateProxy
    : DelegateProxy<UITabBar, UITabBarDelegate>
    , DelegateProxyType 
    , UITabBarDelegate {

    /// Typed parent object.
    public weak private(set) var tabBar: UITabBar?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.tabBar = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxTabBarDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTabBarDelegateProxy(parentObject: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> UITabBarDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: UITabBarDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
}

#endif
