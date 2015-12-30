//
//  Protocols.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

enum ValidationResult {
    case OK(message: String)
    case Empty
    case Validating
    case Failed(message: String)
}

enum SignupState {
    case SignedUp(signedUp: Bool)
}

protocol GitHubAPI {
    func usernameAvailable(username: String) -> Observable<Bool>
    func signup(username: String, password: String) -> Observable<Bool>
}

protocol GitHubValidationService {
    func validateUsername(username: String) -> Observable<ValidationResult>
    func validatePassword(password: String) -> ValidationResult
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> ValidationResult
}

extension ValidationResult {
    var isValid: Bool {
        switch self {
        case .OK:
            return true
        default:
            return false
        }
    }
}

