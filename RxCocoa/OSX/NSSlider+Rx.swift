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
    public var rx_value: Observable<Double> {
        
        return rx_value { [weak self] in
            return self?.doubleValue ?? 0
        }
        
    }
}