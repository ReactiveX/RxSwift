//
//  RxSearchControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 3/17/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)
   
#if !RX_NO_MODULE
   import RxSwift
#endif
   import UIKit

/// For more information take a look at `DelegateProxyType`.
@available(iOS 8.0, *)
open class RxSearchControllerDelegateProxy
    : DelegateProxy<UISearchController, UISearchControllerDelegate>
    , DelegateProxyType 
    , UISearchControllerDelegate {

    /// Typed parent object.
    public weak private(set) var searchController: UISearchController?

    /// - parameter parentObject: Parent object for delegate proxy.
    public init(parentObject: ParentObject) {
        self.searchController = parentObject
        super.init(parentObject: parentObject, delegateProxy: RxSearchControllerDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxSearchControllerDelegateProxy(parentObject: $0) }
    }

    /// For more information take a look at `DelegateProxyType`.
    open class func setCurrentDelegate(_ delegate: UISearchControllerDelegate?, to object: ParentObject) {
        object.delegate = delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open class func currentDelegate(for object: ParentObject) -> UISearchControllerDelegate? {
        return object.delegate
    }
    
}
   
#endif
