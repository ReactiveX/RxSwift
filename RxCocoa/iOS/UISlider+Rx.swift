//
//  UISlider+Rx.swift
//  RxCocoa
//
//  Created by Alexander van der Werff on 28/05/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UISlider {
    
    /**
    Reactive wrapper for `value` property.
    */
    public var rx_value: ControlProperty<Float> {
        return rx_value(getter: { [weak self] in
            self?.value ?? 0.0
        }, setter: { [weak self] value in
            self?.value = value
        })
    }
    
}

#endif
