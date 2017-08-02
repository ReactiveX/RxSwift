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

/// For more information take a look at `DelegateProxyType`.
open class RxTabBarControllerDelegateProxy<P: UITabBarController>
    : DelegateProxy<P, UITabBarControllerDelegate>
    , DelegateProxyType 
    , UITabBarControllerDelegate {

    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxTabBarControllerDelegateProxy<UITabBarController>.self)
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegateFor(_ object: ParentObject) -> UITabBarControllerDelegate? {
        return object.delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UITabBarControllerDelegate?, toObject object: ParentObject) {
        object.delegate = delegate
    }
}

#endif
