//
//  UITextField+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS) || os(visionOS)

import RxSwift
import UIKit

public extension Reactive where Base: UITextField {
    /// Reactive wrapper for `text` property.
    var text: ControlProperty<String?> {
        value
    }

    /// Reactive wrapper for `text` property.
    var value: ControlProperty<String?> {
        base.rx.controlPropertyWithDefaultEvents(
            getter: { textField in
                textField.text
            },
            setter: { textField, value in
                // This check is important because setting text value always clears control state
                // including marked text selection which is important for proper input
                // when IME input method is used.
                if textField.text != value {
                    textField.text = value
                }
            },
        )
    }

    /// Bindable sink for `attributedText` property.
    var attributedText: ControlProperty<NSAttributedString?> {
        base.rx.controlPropertyWithDefaultEvents(
            getter: { textField in
                textField.attributedText
            },
            setter: { textField, value in
                // This check is important because setting text value always clears control state
                // including marked text selection which is important for proper input
                // when IME input method is used.
                if textField.attributedText != value {
                    textField.attributedText = value
                }
            },
        )
    }
}

#endif
