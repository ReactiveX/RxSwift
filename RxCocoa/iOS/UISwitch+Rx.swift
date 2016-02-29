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


extension UISwitch {
    
    /**
    Reactive wrapper for `on` property.
    */
    public var rx_value: ControlProperty<Bool> {
        return UIControl.rx_value(
            self,
            getter: { uiSwitch in
                uiSwitch.on
            }, setter: { uiSwitch, value in
                uiSwitch.on = value
            }
        )
    }
    
}

#endif

