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
public class RxTabBarControllerDelegateProxy
    : DelegateProxy
    , UITabBarControllerDelegate
    , DelegateProxyType {
    
    public static var factory = DelegateProxyFactory { (parentObject: UITabBarController) in
        RxTabBarControllerDelegateProxy(parentObject: parentObject)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let tabBarController: UITabBarController = castOrFatalError(object)
        return tabBarController.delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let tabBarController: UITabBarController = castOrFatalError(object)
        tabBarController.delegate = castOptionalOrFatalError(delegate)
    }
}

#endif
