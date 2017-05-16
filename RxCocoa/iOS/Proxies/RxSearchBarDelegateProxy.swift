//
//  RxSearchBarDelegateProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

/// For more information take a look at `DelegateProxyType`.
public class RxSearchBarDelegateProxy
    : DelegateProxy
    , UISearchBarDelegate
    , DelegateProxyType {

    /// For more information take a look at `DelegateProxyType`.
    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let searchBar: UISearchBar = castOrFatalError(object)
        return searchBar.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let searchBar: UISearchBar = castOrFatalError(object)
        searchBar.delegate = castOptionalOrFatalError(delegate)
    }

    // MARK: Delegate proxy methods
    
#if os(iOS)
    /// For more information take a look at `DelegateProxyType`.
    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
        let searchBar: UISearchBar = castOrFatalError(object)
        return searchBar.createRxDelegateProxy()
    }
#endif
    
}

#endif
