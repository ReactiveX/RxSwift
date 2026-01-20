//
//  BindingExtensions.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension ValidationResult: CustomStringConvertible {
    var description: String {
        switch self {
        case let .ok(message):
            message
        case .empty:
            ""
        case .validating:
            "validating ..."
        case let .failed(message):
            message
        }
    }
}

enum ValidationColors {
    static let okColor = UIColor(red: 138.0 / 255.0, green: 221.0 / 255.0, blue: 109.0 / 255.0, alpha: 1.0)
    static let errorColor = UIColor.red
}

extension ValidationResult {
    var textColor: UIColor {
        switch self {
        case .ok:
            ValidationColors.okColor
        case .empty:
            UIColor.black
        case .validating:
            UIColor.black
        case .failed:
            ValidationColors.errorColor
        }
    }
}

extension Reactive where Base: UILabel {
    var validationResult: Binder<ValidationResult> {
        Binder(base) { label, result in
            label.textColor = result.textColor
            label.text = result.description
        }
    }
}
