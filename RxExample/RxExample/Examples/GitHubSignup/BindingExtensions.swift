//
//  BindingExtensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .OK(message):
            return message
        case .Empty:
            return ""
        case .Validating:
            return "validating ..."
        case let .Failed(message):
            return message
        }
    }
}

struct ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.redColor()
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .OK:
            return ValidationColors.okColor
        case .Empty:
            return UIColor.blackColor()
        case .Validating:
            return UIColor.blackColor()
        case .Failed:
            return ValidationColors.errorColor
        }
    }
}

extension UILabel {
    var ex_validationResult: AnyObserver<ValidationResult> {
        return UIBindingObserver(UIElement: self) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }.asObserver()
    }
}