//
//  MockGitHubAPI.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

class MockGitHubAPI : GitHubAPI {
    let _usernameAvailable: @Sendable (String) -> Observable<Bool>
    let _signup: @Sendable ((String, String)) -> Observable<Bool>

    init(
        usernameAvailable: @escaping @Sendable (String) -> Observable<Bool> = notImplemented(),
        signup: @escaping @Sendable ((String, String)) -> Observable<Bool> = notImplemented()
        ) {
        _usernameAvailable = usernameAvailable
        _signup = signup
    }

    func usernameAvailable(_ username: String) -> Observable<Bool> {
        _usernameAvailable(username)
    }

    func signup(_ username: String, password: String) -> Observable<Bool> {
        _signup((username, password))
    }
}
