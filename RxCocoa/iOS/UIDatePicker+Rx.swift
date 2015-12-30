//
//  UIDatePicker+Rx.swift
//  RxCocoa
//
//  Created by Daniel Tartaglia on 5/31/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
        return rx_value(getter: { [weak self] in
            self?.date ?? NSDate()
        }, setter: { [weak self] value in
            self?.date = value
        })
    }
    
}

#endif
