//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

extension UITextField : RxTextInput {
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        return UIControl.rx_value(
            self,
            getter: { textField in
                textField.text ?? ""
            }, setter: { textField, value in
                if textField.text != value {
                    textField.text = value
                }
            }
        )
    }
    
}

#endif
