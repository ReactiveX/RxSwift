//
//  NSControl+Rx.swift
//  RxCocoa
//
//  Created by Junior B. on 24/05/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import Cocoa

extension NSSlider {
    
    /**
    Reactive wrapper for `value` property.
    */
    public var rx_value: ControlProperty<Double> {
        return rx_value(getter: { [weak self] in
            return self?.doubleValue ?? 0
        }, setter: { [weak self] value in
            self?.doubleValue = value
        })
    }
    
}