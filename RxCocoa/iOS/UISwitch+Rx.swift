//
//  UISwitch+Rx.swift
//  RxCocoa
//
//  Created by Carlos García on 8/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
#if !RX_NO_MODULE
import RxSwift
#endif


extension UISwitch {
    
    public var rx_value: Observable<Bool> {
        return rx_value { [unowned self] in self.on }
    }
    
}