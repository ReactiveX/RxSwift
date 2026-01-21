//
//  UIStepper+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 9/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UIStepper {
    /// Reactive wrapper for `value` property.
    var value: ControlProperty<Double> {
        base.rx.controlPropertyWithDefaultEvents(
            getter: { stepper in
                stepper.value
            }, setter: { stepper, value in
                stepper.value = value
            },
        )
    }
}

#endif
