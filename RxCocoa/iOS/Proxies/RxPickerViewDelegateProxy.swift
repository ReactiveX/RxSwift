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

        // Register known implementationss
        public static func registerKnownImplementations() {
            self.register { RxPickerViewDelegateProxy(parentObject: $0) }
        }

        /// For more information take a look at `DelegateProxyType`.
        open override class func setCurrentDelegate(_ delegate: UIPickerViewDelegate?, toObject object: ParentObject) {
            object.delegate = delegate
        }
        
        /// For more information take a look at `DelegateProxyType`.
        open override class func currentDelegate(for object: ParentObject) -> UIPickerViewDelegate? {
            return object.delegate
        }
    }
#endif
