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

    public class RxPickerViewDelegateProxy
        : DelegateProxy
        , DelegateProxyType
        , UIPickerViewDelegate {

        /// For more information take a look at `DelegateProxyType`.
        public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {
            let pickerView: UIPickerView = castOrFatalError(object)
            return pickerView.createRxDelegateProxy()
        }
        
        /// For more information take a look at `DelegateProxyType`.
        public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
            let pickerView: UIPickerView = castOrFatalError(object)
            pickerView.delegate = castOptionalOrFatalError(delegate)
        }
        
        /// For more information take a look at `DelegateProxyType`.
        public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
            let pickerView: UIPickerView = castOrFatalError(object)
            return pickerView.delegate
        }
    }
#endif
