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
open class RxSearchControllerDelegateProxy<P: UISearchController>
    : DelegateProxy<P, UISearchControllerDelegate>
    , DelegateProxyType 
    , UISearchControllerDelegate {

    public static var factory: DelegateProxyFactory {
        return DelegateProxyFactory.sharedFactory(for: RxSearchControllerDelegateProxy<UISearchController>.self)
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open override class func setCurrentDelegate(_ delegate: UISearchControllerDelegate?, toObject object: ParentObject) {
        object.delegate = delegate
    }
    
    /// For more information take a look at `DelegateProxyType`.
    open override class func currentDelegateFor(_ object: ParentObject) -> UISearchControllerDelegate? {
        return object.delegate
    }
    
}
   
#endif
