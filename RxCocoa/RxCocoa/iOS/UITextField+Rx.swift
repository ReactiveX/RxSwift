//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UITextField {
    public var rx_text: Observable<String> {
        return rx_value { [weak self] in
            self?.text ?? ""
        }
    }
}