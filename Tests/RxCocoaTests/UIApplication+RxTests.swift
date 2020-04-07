//
//  UIApplication+RxTests.swift
//  Tests
//
//  Created by Zsolt Kovacs on 01/17/20.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UIApplicationTests : RxTest {
    func testApplication_didEnterBackground() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.didEnterBackground.subscribe(onNext: { didReceiveNotification = true })
        
        NotificationCenter.default.post(name: UIApplication.didEnterBackgroundNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_willEnterForeground() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.willEnterForeground.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.willEnterForegroundNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }


    func testApplication_didFinishLaunching() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.didFinishLaunching.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.didFinishLaunchingNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_didBecomeActive() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.didBecomeActive.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_willResignActive() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.willResignActive.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_didReceiveMemoryWarning() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.didReceiveMemoryWarning.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.didReceiveMemoryWarningNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_willTerminate() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.willTerminate.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.willTerminateNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_significantTimeChange() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.significantTimeChange.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.significantTimeChangeNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_backgroundRefreshStatusDidChange() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.backgroundRefreshStatusDidChange.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.backgroundRefreshStatusDidChangeNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_protectedDataWillBecomeUnavailable() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.protectedDataWillBecomeUnavailable.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_protectedDataDidBecomeAvailable() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.protectedDataDidBecomeAvailable.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.protectedDataDidBecomeAvailableNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }

    func testApplication_userDidTakeScreenshot() {
        var didReceiveNotification = false
        let subscription = UIApplication.rx.userDidTakeScreenshot.subscribe(onNext: { didReceiveNotification = true })

        NotificationCenter.default.post(name: UIApplication.userDidTakeScreenshotNotification, object: UIApplication.shared)

        XCTAssertTrue(didReceiveNotification)
        subscription.dispose()
    }
}
