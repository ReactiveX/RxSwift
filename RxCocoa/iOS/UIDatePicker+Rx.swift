//
//  UIDatePicker.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UIDatePicker {
    
    /**
    Reactive wrapper for `date` property.
    */
    public var rx_date: ControlProperty<NSDate> {
        return rx_value(getter: { [unowned self] in
            self.date
        }, setter: { [weak self] value in
            self?.date = value
        })
    }
    
}

#endif
