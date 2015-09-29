//
//  UIStepper+Rx.swift
//  RxCocoa
//
//  Created by Yuta ToKoRo on 9/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
        return rx_value(getter: { [unowned self] in
            self.value
        }, setter: { [weak self] value in
            self?.value = value
        })
    }
    
}

#endif

