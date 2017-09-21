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

    extension NSTextStorage: HasDelegate {
        public typealias Delegate = NSTextStorageDelegate
    }

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
    }
#endif
