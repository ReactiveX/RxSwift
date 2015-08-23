//
//  UISlider+Rx.swift
//  RxCocoa
//
//  Created by Alexander van der Werff on 28/05/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UISlider {
    public var rx_value: Observable<Float> {
        return rx_value { [unowned self] in self.value }
    }
}