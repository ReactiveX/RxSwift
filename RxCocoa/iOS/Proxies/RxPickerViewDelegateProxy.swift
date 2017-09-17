//
//  RxPickerViewDelegateProxy.swift
//  RxCocoa
//
//  Created by Segii Shulga on 5/12/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

#if !RX_NO_MODULE
    import RxSwift
#endif
    import UIKit

    open class RxPickerViewDelegateProxy
        : DelegateProxy<UIPickerView, UIPickerViewDelegate>
        , DelegateProxyType 
        , UIPickerViewDelegate {

        /// Typed parent object.
        public weak private(set) var pickerView: UIPickerView?

        /// - parameter parentObject: Parent object for delegate proxy.
        public init(parentObject: ParentObject) {
            self.pickerView = parentObject
            super.init(parentObject: parentObject, delegateProxy: RxPickerViewDelegateProxy.self)
        }

        // Register known implementationss
        public static func registerKnownImplementations() {
            self.register { RxPickerViewDelegateProxy(parentObject: $0) }
        }

        /// For more information take a look at `DelegateProxyType`.
        open class func setCurrentDelegate(_ delegate: UIPickerViewDelegate?, to object: ParentObject) {
            object.delegate = delegate
        }
        
        /// For more information take a look at `DelegateProxyType`.
        open class func currentDelegate(for object: ParentObject) -> UIPickerViewDelegate? {
            return object.delegate
        }
    }
#endif
