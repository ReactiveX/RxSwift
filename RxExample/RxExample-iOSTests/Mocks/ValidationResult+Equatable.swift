//
//  ValidationResult+Equatable.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// MARK: Equatable

extension ValidationResult : Equatable {

}

func == (lhs: ValidationResult, rhs: ValidationResult) -> Bool {
    switch (lhs, rhs) {
    case (.OK, .OK):
        return true
    case (.Empty, .Empty):
        return true
    case (.Validating, .Validating):
        return true
    case (.Failed, .Failed):
        return true
    default:
        return false
    }
}