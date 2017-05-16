//
//  MockGitHubAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

class MockGitHubAPI : GitHubAPI {
    let _usernameAvailable: (String) -> Observable<Bool>
    let _signup: (String, String) -> Observable<Bool>

    init(
        usernameAvailable: @escaping (String) -> Observable<Bool> = notImplemented(),
        signup: @escaping (String, String) -> Observable<Bool> = notImplemented()
        ) {
        _usernameAvailable = usernameAvailable
        _signup = signup
    }

    func usernameAvailable(_ username: String) -> Observable<Bool> {
        return _usernameAvailable(username)
    }

    func signup(_ username: String, password: String) -> Observable<Bool> {
        return _signup(username, password)
    }
}
