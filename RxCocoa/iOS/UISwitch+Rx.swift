//
//  UISwitch+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension Reactive where Base: UISwitch {
    
    /**
    Reactive wrapper for `on` property.
    
    **⚠️Unlike other controls, Apple is reusing instances of UISwitch or a there is a leak,
     so underlying observable sequence won't complete when nothing holds a strong reference
     to UISwitch.⚠️**
    */
    public var value: ControlProperty<Bool> {
        return UIControl.rx.value(
            self.base,
            getter: { uiSwitch in
                uiSwitch.isOn
            }, setter: { uiSwitch, value in
                uiSwitch.isOn = value
            }
        )
    }
    
}

#endif

