//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UITextField {
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        return rx_value(getter: { [weak self] in
            self?.text ?? ""
        }, setter: { [weak self] value in
            self?.text = value
        })
    }
    
}

#endif
