//
//  UIStepper+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 9/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension UIStepper {
    
    /**
    Reactive wrapper for `value` property.
    */
    public var rx_value: ControlProperty<Double> {
        return UIControl.rx_value(
            self,
            key: "value",
            getter: { stepper in
                stepper.value
            }, setter: { stepper, value in
                stepper.value = value
            }
        )
    }
    
}

#endif

