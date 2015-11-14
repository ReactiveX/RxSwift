//
//  GitHubAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 4/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif

enum SignupState: Equatable {
    case InitialState
    case SigningUp
    case SignedUp(signedUp: Bool)
}

func ==(lhs: SignupState, rhs: SignupState) -> Bool {
    switch (lhs, rhs) {
    case (.InitialState, .InitialState):
        return true
    case (.SigningUp, .SigningUp):
        return true
    case (.SignedUp(let lhsSignup), .SignedUp(let rhsSignup)):
        return lhsSignup == rhsSignup
    default:
        return false
    }
}

class GitHubAPI {
    let dataScheduler: ImmediateSchedulerType
    let URLSession: NSURLSession

    init(dataScheduler: ImmediateSchedulerType, URLSession: NSURLSession) {
        self.dataScheduler = dataScheduler
        self.URLSession = URLSession
    }
    
    func usernameAvailable(username: String) -> Observable<Bool> {
        // this is ofc just mock, but good enough
        
        let URL = NSURL(string: "https://github.com/\(URLEscape(username))")!
        let request = NSURLRequest(URL: URL)
        return self.URLSession.rx_response(request)
            .map { (maybeData, response) in
                return response.statusCode == 404
            }
            .observeOn(self.dataScheduler)
            .catchErrorJustReturn(false)
    }
    
    func signup(username: String, password: String) -> Observable<SignupState> {
        // this is also just a mock
        let signupResult = SignupState.SignedUp(signedUp: arc4random() % 5 == 0 ? false : true)
        return just(signupResult)
            .concat(never())
            .throttle(2, MainScheduler.sharedInstance)
            .startWith(SignupState.SigningUp)
    }
}