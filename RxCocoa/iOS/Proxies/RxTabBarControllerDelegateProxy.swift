//
//  RxTabBarControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

extension UITabBarController: HasDelegate {
    public typealias Delegate = UITabBarControllerDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxTabBarControllerDelegateProxy
    : DelegateProxy<UITabBarController, UITabBarControllerDelegate>
    , DelegateProxyType 
    , UITabBarControllerDelegate {

    /// Typed parent object.
    public weak private(set) var tabBar: UITabBarController?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.tabBar = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxTabBarControllerDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxTabBarControllerDelegateProxy(parentObject: $0) }
    }
}

#endif
