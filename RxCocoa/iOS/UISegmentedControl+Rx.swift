//
//  UISegmentedControl+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension UISegmentedControl {
    
    public var rx_value: ControlProperty<Int> {
        return rx_value(getter: { [unowned self] in
            self.selectedSegmentIndex
        }, setter: { [weak self] value in
            self?.selectedSegmentIndex = value
        })
    }
    
}