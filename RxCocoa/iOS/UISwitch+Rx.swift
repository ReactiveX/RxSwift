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
    */
    public var value: ControlProperty<Bool> {
        return Reactive<UIControl>.value(
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

