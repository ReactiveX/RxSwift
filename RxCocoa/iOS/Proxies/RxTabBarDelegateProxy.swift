//
//  RxTabBarDelegateProxy.swift
//  Rx
//
//  Created by Jesse Farless on 5/14/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

#if !RX_NO_MODULE
import RxSwift
#endif

/**
 For more information take a look at `DelegateProxyType`.
 */
public class RxTabBarDelegateProxy
    : DelegateProxy
    , UITabBarDelegate
    , DelegateProxyType {

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func currentDelegateFor(object: AnyObject) -> AnyObject? {
        let tabBar: UITabBar = castOrFatalError(object)
        return tabBar.delegate
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public class func setCurrentDelegate(delegate: AnyObject?, toObject object: AnyObject) {
        let tabBar: UITabBar = castOrFatalError(object)
        tabBar.delegate = castOptionalOrFatalError(delegate)
    }

    /**
     For more information take a look at `DelegateProxyType`.
     */
    public override class func createProxyForObject(object: AnyObject) -> AnyObject {
        let tabBar = (object as! UITabBar)

        return castOrFatalError(tabBar.rx_createDelegateProxy())
    }

}

#endif