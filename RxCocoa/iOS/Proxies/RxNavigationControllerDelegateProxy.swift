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
        : DelegateProxy
        , UINavigationControllerDelegate
        , DelegateProxyType {

        /// For more information take a look at `DelegateProxyType`.
        public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
            let navigationController: UINavigationController = castOrFatalError(object)
            return navigationController.delegate
        }

        /// For more information take a look at `DelegateProxyType`.
        public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
            let navigationController: UINavigationController = castOrFatalError(object)
            navigationController.delegate = castOptionalOrFatalError(delegate)
        }

        /// For more information take a look at `DelegateProxyType`.
        open override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
            let navigationController: UINavigationController = castOrFatalError(object)
            return navigationController.createRxDelegateProxy()
        }
    }

    #if os(iOS)
        extension RxNavigationControllerDelegateProxy: UIImagePickerControllerDelegate {

        }
    #endif

#endif
