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
        return UIControl.rx.value(
            self.base,
            getter: { stepper in
                stepper.value
            }, setter: { stepper, value in
                stepper.value = value
            }
        )
    }

    /// Reactive wrapper for `stepValue` property.
    public var stepValue: ControlProperty<Double> {
        return UIControl.rx.value(
            self.base,
            getter: { stepper in
                stepper.stepValue
            }, setter: { stepper, stepValue in
                stepper.stepValue = stepValue
            }
        )
    }
    
}

#endif

