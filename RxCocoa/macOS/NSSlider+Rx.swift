//
//  NSSlider+Rx.swift
//  RxCocoa
//
//  Created by Junior B. on 24/05/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS)

import Cocoa
import RxSwift

public extension Reactive where Base: NSSlider {
    /// Reactive wrapper for `value` property.
    var value: ControlProperty<Double> {
        base.rx.controlProperty(
            getter: { control -> Double in
                return control.doubleValue
            },
            setter: { control, value in
                control.doubleValue = value
            },
        )
    }
}

#endif
