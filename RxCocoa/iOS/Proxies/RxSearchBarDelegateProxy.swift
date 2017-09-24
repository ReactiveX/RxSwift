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

extension UISearchBar: HasDelegate {
    public typealias Delegate = UISearchBarDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxSearchBarDelegateProxy
    : DelegateProxy<UISearchBar, UISearchBarDelegate>
    , DelegateProxyType 
    , UISearchBarDelegate {

    /// Typed parent object.
    public weak private(set) var searchBar: UISearchBar?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.searchBar = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxSearchBarDelegateProxy.self)
    }

    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxSearchBarDelegateProxy(parentObject: $0) }
    }
}

#endif
