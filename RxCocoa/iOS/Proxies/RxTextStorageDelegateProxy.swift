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

        /// Typed parent object.
        public weak private(set) var textStorage: NSTextStorage?

        /// - parameter parentObject: Parent object for delegate proxy.
        public init(parentObject: NSTextStorage) {
            self.textStorage = parentObject
            super.init(parentObject: parentObject, delegateProxy: RxTextStorageDelegateProxy.self)
        }

        // Register known implementations
        public static func registerKnownImplementations() {
            self.register { RxTextStorageDelegateProxy(parentObject: $0) }
        }

        /// For more information take a look at `DelegateProxyType`.
        open class func setCurrentDelegate(_ delegate: NSTextStorageDelegate?, to object: ParentObject) {
            object.delegate = delegate
        }
        
        /// For more information take a look at `DelegateProxyType`.
        open class func currentDelegate(for object: ParentObject) -> NSTextStorageDelegate? {
            return object.delegate
        }
    }
#endif
