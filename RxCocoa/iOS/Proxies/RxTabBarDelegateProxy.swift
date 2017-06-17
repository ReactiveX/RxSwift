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
public class RxTabBarDelegateProxy
    : DelegateProxy
    , UITabBarDelegate
    , DelegateProxyType {
    
    public static var factory = DelegateProxyFactory { (parentObject: UITabBar) in
        RxTabBarDelegateProxy(parentObject: parentObject)
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tabBar: UITabBar = castOrFatalError(object)
        return tabBar.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tabBar: UITabBar = castOrFatalError(object)
        tabBar.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif
