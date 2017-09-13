//
//  RxTextStorageDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
    
    #if !RX_NO_MODULE
        import RxSwift
    #endif
    import UIKit
    
    open class RxTextStorageDelegateProxy
        : DelegateProxy<NSTextStorage, NSTextStorageDelegate>
        , DelegateProxyType 
        , NSTextStorageDelegate {
        public static var factory: DelegateProxyFactory {
            return DelegateProxyFactory.sharedFactory(for: RxTextStorageDelegateProxy.self)
        }
        
        /// For more information take a look at `DelegateProxyType`.
        open override class func setCurrentDelegate(_ delegate: NSTextStorageDelegate?, toObject object: ParentObject) {
            object.delegate = delegate
        }
        
        /// For more information take a look at `DelegateProxyType`.
        open override class func currentDelegate(for object: ParentObject) -> NSTextStorageDelegate? {
            return object.delegate
        }
    }
#endif
