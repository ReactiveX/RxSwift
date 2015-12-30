//
//  RxExample_iOSTests.swift
//  RxExample-iOSTests
//
//  Created by Krunoslav Zaher on 12/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import XCTest

import RxSwift
import RxTests
import RxCocoa

let resolution: NSTimeInterval = 0.2 // seconds

// MARK: Concrete tests

/**
This is just an example of one way how this can be done.
*/
class RxExample_iOSTests
    : XCTestCase {

    let booleans = ["t" : true, "f" : false]
    let events = ["x" : ()]
    let errors = [
        "#1" : NSError(domain: "Some unknown error maybe", code: -1, userInfo: nil),
        "#u" : NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: nil)
    ]
    let validations = [
        "e" : ValidationResult.Empty,
        "f" : ValidationResult.Failed(message: ""),
        "o" : ValidationResult.OK(message: "Validated"),
        "v" : ValidationResult.Validating
    ]

    let stringValues = [
        "u1" : "verysecret",
        "u2" : "secretuser",
        "u3" : "secretusername",
        "p1" : "huge secret",
        "p2" : "secret",
        "e" : ""
    ]

    ////////////////////////////////////////////////////////////////////////////////
    // This is test of enabled user interface elements.
    // I guess you could do this for view models, but this is probably overkill to
    // do.
    //
    // It's probably more suitable for some vital components of your system, but 
    // the pricinciple is the same.
    ////////////////////////////////////////////////////////////////////////////////
    func testGitHubSignup_vanillaObservables_1_testEnabledUserInterfaceElements() {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)

        // mock the universe
        let mockAPI = mockGithubAPI(scheduler)

        // expected events and test data
        let (
            usernameEvents,
            passwordEvents,
            repeatedPasswordEvents,
            loginTapEvents,

            expectedValidatedUsernameEvents,
            expectedSignupEnabledEvents
        ) = (
            scheduler.parseEventsAndTimes("e---u1----u2-----u3-----------------", values: stringValues).first!,
            scheduler.parseEventsAndTimes("e----------------------p1-----------", values: stringValues).first!,
            scheduler.parseEventsAndTimes("e---------------------------p2---p1-", values: stringValues).first!,
            scheduler.parseEventsAndTimes("------------------------------------", values: events).first!,

            scheduler.parseEventsAndTimes("e---v--f--v--f---v--o----------------", values: validations).first!,
            scheduler.parseEventsAndTimes("f--------------------------------t---", values: booleans).first!
        )

        let wireframe = MockWireframe()
        let validationService = GitHubDefaultValidationService(API: mockAPI)

        let viewModel = GithubSignupViewModel1(
            input: (
                username: scheduler.createHotObservable(usernameEvents).asObservable(),
                password: scheduler.createHotObservable(passwordEvents).asObservable(),
                repeatedPassword: scheduler.createHotObservable(repeatedPasswordEvents).asObservable(),
                loginTaps: scheduler.createHotObservable(loginTapEvents).asObservable()
            ),
            dependency: (
                API: mockAPI,
                validationService: validationService,
                wireframe: wireframe
            )
        )

        // run experiment
        let recordedSignupEnabled = scheduler.record(viewModel.signupEnabled)
        let recordedValidatedUsername = scheduler.record(viewModel.validatedUsername)

        scheduler.start()

        // validate
        XCTAssertEqual(recordedValidatedUsername.events, expectedValidatedUsernameEvents)
        XCTAssertEqual(recordedSignupEnabled.events, expectedSignupEnabledEvents)
    }

    func testGitHubSignup_drivers_2_testEnabledUserInterfaceElements() {
        let scheduler = TestScheduler(initialClock: 0, resolution: resolution, simulateProcessingDelay: false)

        // mock the universe
        let mockAPI = mockGithubAPI(scheduler)

        // expected events and test data
        let (
            usernameEvents,
            passwordEvents,
            repeatedPasswordEvents,
            loginTapEvents,

            expectedValidatedUsernameEvents,
            expectedSignupEnabledEvents
        ) = (
            scheduler.parseEventsAndTimes("e---u1----u2-----u3-----------------", values: stringValues).first!,
            scheduler.parseEventsAndTimes("e----------------------p1-----------", values: stringValues).first!,
            scheduler.parseEventsAndTimes("e---------------------------p2---p1-", values: stringValues).first!,
            scheduler.parseEventsAndTimes("------------------------------------", values: events).first!,

            scheduler.parseEventsAndTimes("e---v--f--v--f---v--o----------------", values: validations).first!,
            scheduler.parseEventsAndTimes("f--------------------------------t---", values: booleans).first!
        )

        let wireframe = MockWireframe()
        let validationService = GitHubDefaultValidationService(API: mockAPI)

        let viewModel = GithubSignupViewModel2(
            input: (
                username: scheduler.createHotObservable(usernameEvents).asDriver(onErrorJustReturn: ""),
                password: scheduler.createHotObservable(passwordEvents).asDriver(onErrorJustReturn: ""),
                repeatedPassword: scheduler.createHotObservable(repeatedPasswordEvents).asDriver(onErrorJustReturn: ""),
                loginTaps: scheduler.createHotObservable(loginTapEvents).asDriver(onErrorJustReturn: ())
            ),
            dependency: (
                API: mockAPI,
                validationService: validationService,
                wireframe: wireframe
            )
        )

        /**
        This is important because driver will try to ensure that elements are being pumped on main scheduler,
        and that sometimes means that it will get queued using `dispatch_async` to main dispatch queue and
        not get flushed until end of the test.
        
        This method enables using mock schedulers for while testing drivers.
        */
        driveOnScheduler(scheduler) {
            // run experiment
            let recordedSignupEnabled = scheduler.record(viewModel.signupEnabled)
            let recordedValidatedUsername = scheduler.record(viewModel.validatedUsername)

            scheduler.start()
            
            // validate
            XCTAssertEqual(recordedValidatedUsername.events, expectedValidatedUsernameEvents)
            XCTAssertEqual(recordedSignupEnabled.events, expectedSignupEnabledEvents)
        }
    }
}

// MARK: Mocks

extension RxExample_iOSTests {
    func mockGithubAPI(scheduler: TestScheduler) -> GitHubAPI {
        return MockGitHubAPI(
            usernameAvailable: scheduler.mock(booleans, errors: errors) { (username) -> String in
                if username == "secretusername" {
                    return "---t"
                }
                else if username == "secretuser" {
                    return "---#1"
                }
                else {
                    return "---f"
                }
            },
            signup: scheduler.mock(booleans, errors: errors) { (username, password) -> String in
                if username == "secretusername" && password == "secret" {
                    return "--t"
                }
                else {
                    return "--f"
                }
            }
        )
    }
}

// MARK: Mocks

