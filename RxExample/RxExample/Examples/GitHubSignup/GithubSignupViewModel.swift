//
//  GithubSignupViewModel.swift
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

class GithubSignupViewModel {

    private let API: GitHubAPI
    private let validationService: GitHubValidationService
    private let wireframe: Wireframe

    // inputs {

    let username = Variable("")
    let password = Variable("")
    let repeatedPassword = Variable("")

    let loginTaps = PublishSubject<Void>()

    // }

    // outputs {

    //
    let validatedUsername: Observable<ValidationResult>
    let validatedPassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>

    // Is signup button enabled
    let signupEnabled: Observable<Bool>

    // Has user signed in
    let signedIn: Observable<Bool>

    // Is signing process in progress
    let signingIn: Observable<Bool>

    // }

    init(API: GitHubAPI, validationService: GitHubValidationService, wireframe: Wireframe) {
        self.API = API
        self.validationService = validationService
        self.wireframe = wireframe

        validatedUsername = username
            .flatMapLatest { username in
                return validationService.validateUsername(username)
                    .observeOn(MainScheduler.sharedInstance)
                    .catchErrorJustReturn(.Failed(message: "Error contacting server"))
            }
            .shareReplay(1)

        validatedPassword = password
            .map { password in
                return validationService.validatePassword(password)
            }
            .shareReplay(1)

        validatedPasswordRepeated = combineLatest(password, repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
            .shareReplay(1)

        let signingIn = ActivityIndicator()
        self.signingIn = signingIn.asObservable()

        let usernameAndPassword = combineLatest(username, password) { ($0, $1) }

        signedIn = loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest { (username, password) in
                return API.signup(username, password: password)
                    .observeOn(MainScheduler.sharedInstance)
                    .catchErrorJustReturn(false)
                    .trackActivity(signingIn)
            }
            .flatMapLatest { loggedIn -> Observable<Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." : "Mock: Sign in to GitHub failed"
                return wireframe.promptFor(message, cancelAction: "OK", actions: [])
                    // propagate original value
                    .map { _ in
                        loggedIn
                    }
            }
            .shareReplay(1)
        
        signupEnabled = combineLatest(
            validatedUsername,
            validatedPassword,
            validatedPasswordRepeated,
            signingIn.asObservable()
        )   { username, password, repeatPassword, signingIn in
                username.isValid &&
                password.isValid &&
                repeatPassword.isValid &&
                !signingIn
            }
            .shareReplay(1)
    }
}