//
//  RxNavigationControllerDelegateProxy.swift
//  RxCocoa
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

    import UIKit
    #if !RX_NO_MODULE
        import RxSwift
    #endif

    /// For more information take a look at `DelegateProxyType`.
    open class RxNavigationControllerDelegateProxy
        : DelegateProxy<UINavigationController, UINavigationControllerDelegate>
        , DelegateProxyType 
        , UINavigationControllerDelegate {

        public static var factory: DelegateProxyFactory {
            return DelegateProxyFactory.sharedFactory(for: RxNavigationControllerDelegateProxy.self)
        }

        /// For more information take a look at `DelegateProxyType`.
        open override class func currentDelegate(for object: ParentObject) -> UINavigationControllerDelegate? {
            return object.delegate
        }

        /// For more information take a look at `DelegateProxyType`.
        open override class func setCurrentDelegate(_ delegate: UINavigationControllerDelegate?, toObject object: ParentObject) {
            object.delegate = delegate
        }
    }
#endif
