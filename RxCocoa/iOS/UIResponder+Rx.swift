//
//  UIResponder+Rx.swift
//  Rx
//
//  Created by DragonCherry on 7/14/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import UIKit
    
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit
    
extension Reactive where Base: UIControl {
        
    /// Bindable sink for `isFirstResponder` property.
    public var isFirstResponder: UIBindingObserver<Base, Bool> {
        return UIBindingObserver(UIElement: self.base) { control, value in
            if control.isFirstResponder != value {
                _ = value ? control.becomeFirstResponder() : control.resignFirstResponder()
            }
        }
    }
}

#endif
