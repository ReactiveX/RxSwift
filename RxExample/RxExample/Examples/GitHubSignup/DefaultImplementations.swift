//
//  DefaultImplementations.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif


class GitHubDefaultValidationService: GitHubValidationService {
    let API: GitHubAPI

    static let sharedValidationService = GitHubDefaultValidationService(API: GitHubDefaultAPI.sharedAPI)

    init (API: GitHubAPI) {
        self.API = API
    }
    
    // validation
    
    let minPasswordCount = 5
    
    func validateUsername(_ username: String) -> Observable<ValidationResult> {
        if username.characters.count == 0 {
            return Observable.just(.empty)
        }
        

        // this obviously won't be
        if username.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) != nil {
            return Observable.just(.failed(message: "Username can only contain numbers or digits"))
        }
        
        let loadingValue = ValidationResult.validating
        
        return API
            .usernameAvailable(username)
            .map { available in
                if available {
                    return .ok(message: "Username available")
                }
                else {
                    return .failed(message: "Username already taken")
                }
            }
            .startWith(loadingValue)
    }
    
    func validatePassword(_ password: String) -> ValidationResult {
        let numberOfCharacters = password.characters.count
        if numberOfCharacters == 0 {
            return .empty
        }
        
        if numberOfCharacters < minPasswordCount {
            return .failed(message: "Password must be at least \(minPasswordCount) characters")
        }
        
        return .ok(message: "Password acceptable")
    }
    
    func validateRepeatedPassword(_ password: String, repeatedPassword: String) -> ValidationResult {
        if repeatedPassword.characters.count == 0 {
            return .empty
        }
        
        if repeatedPassword == password {
            return .ok(message: "Password repeated")
        }
        else {
            return .failed(message: "Password different")
        }
    }
}


class GitHubDefaultAPI : GitHubAPI {
    let URLSession: Foundation.URLSession

    static let sharedAPI = GitHubDefaultAPI(
        URLSession: Foundation.URLSession.shared
    )

    init(URLSession: Foundation.URLSession) {
        self.URLSession = URLSession
    }
    
    func usernameAvailable(_ username: String) -> Observable<Bool> {
        // this is ofc just mock, but good enough
        
        let url = URL(string: "https://github.com/\(username.URLEscaped)")!
        let request = URLRequest(url: url)
        return self.URLSession.rx_response(request)
            .map { (maybeData, response) in
                return response.statusCode == 404
            }
            .catchErrorJustReturn(false)
    }
    
    func signup(_ username: String, password: String) -> Observable<Bool> {
        // this is also just a mock
        let signupResult = arc4random() % 5 == 0 ? false : true
        return Observable.just(signupResult)
            .concat(Observable.never())
            .throttle(0.4, scheduler: MainScheduler.instance)
            .take(1)
    }
}
