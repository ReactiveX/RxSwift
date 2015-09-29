//
//  UISlider+Rx.swift
//  RxCocoa
//
//  Created by Alexander van der Werff on 28/05/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
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
        return rx_value(getter: { [unowned self] in
            self.value
        }, setter: { [weak self] value in
            self?.value = value
        })
    }
    
}

#endif
