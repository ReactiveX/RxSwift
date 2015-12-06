//
//  ValidationService.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

typealias ValidationObservable = Observable<ValidationResult>

class ValidationService {
    let API: GitHubAPI
    
    init (API: GitHubAPI) {
        self.API = API
    }
    
    // validation
    
    let minPasswordCount = 5
    
    func validateUsername(username: String) -> ValidationObservable {
        if username.characters.count == 0 {
            return just((false, nil))
        }
        
        // this obviously won't be
        if username.rangeOfCharacterFromSet(NSCharacterSet.alphanumericCharacterSet().invertedSet) != nil {
            return just((false, "Username can only contain numbers or digits"))
        }
        
        let loadingValue = (valid: nil as Bool?, message: "Checking availabilty ..." as String?)
        
        return API.usernameAvailable(username)
            .map { available in
                if available {
                    return (true, "Username available")
                }
                else {
                    return (false, "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return (false, nil)
        }
        
        if numberOfCharacters < minPasswordCount {
            return (false, "Password must be at least \(minPasswordCount) characters")
        }
        
        return (true, "Password acceptable")
    }
    
    func validateRepeatedPassword(password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.characters.count == 0 {
            return (false, nil)
        }
        
        if repeatedPassword == password {
            return (true, "Password repeated")
        }
        else {
            return (false, "Password different")
        }
    }
}
