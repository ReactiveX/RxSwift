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
        return rx_value(getter: { [weak self] in
            self?.value ?? 0
        }, setter: { [weak self] value in
            self?.value = value
        })
    }
    
}

#endif

