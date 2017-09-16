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
open class RxSearchBarDelegateProxy
    : DelegateProxy<UISearchBar, UISearchBarDelegate>
    , DelegateProxyType 
    , UISearchBarDelegate {

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxSearchBarDelegateProxy(parentObject: $0) }
    }

    // MARK: Delegate proxy methods
    
    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegate(for object: ParentObject) -> UISearchBarDelegate? {
        return object.delegate
    }

    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UISearchBarDelegate?, toObject object: ParentObject) {
        object.delegate = delegate
    }
}

#endif
