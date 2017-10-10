//
//  UIStepper+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 9/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif

extension Reactive where Base: UIStepper {
    
    /// Reactive wrapper for `value` property.
    public var value: ControlProperty<Double> {
        return base.rx.controlPropertyWithDefaultEvents(
            getter: { stepper in
                stepper.value
            }, setter: { stepper, value in
                stepper.value = value
            }
        )
    }
    
}

#endif

