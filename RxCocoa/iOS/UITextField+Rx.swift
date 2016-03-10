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

extension UITextField {
    
    /**
    Reactive wrapper for `text` property.
    */
    public var rx_text: ControlProperty<String> {
        return UIControl.rx_value(
            self,
            getter: { textField in
                textField.text ?? ""
            }, setter: { textField, value in
                textField.text = value
            }
        )
    }
    
    /**
    Reactive wrapper for `editing` property.
    */
    public var rx_editing: ControlProperty<Bool> {
        return UIControl.rx_value(
            self,
            getter: { textField in
                textField.editing
            }, setter: { textField, value in
                if value {
                    textField.becomeFirstResponder()
                } else {
                    textField.resignFirstResponder()
                }
            }
        )
    }
}

#endif
