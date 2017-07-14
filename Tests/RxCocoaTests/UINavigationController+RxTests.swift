//
//  UINavigationController+RxTests.swift
//  Tests
//
//  Created by Diogo on 13/04/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UINavigationControllerTests : RxTest {
}

extension UINavigationControllerTests {

    func testWillShow() {
        let navigationController = UINavigationController()

        let viewController = UIViewController()
        var presentedViewController = UIViewController()

        XCTAssertNotEqual(viewController, presentedViewController)

        let animated = true
        var presentedAnimated = false

        XCTAssertNotEqual(animated, presentedAnimated)

        _ = navigationController.rx.willShow
            .subscribe(onNext: { showEvent in
                let (viewController, animated) = showEvent
                presentedViewController = viewController
                presentedAnimated = animated
            })

        _ = navigationController.rx.didShow
            .subscribe(onNext: { _ in
                XCTFail("Should not be called")
            })

        navigationController.delegate!.navigationController!(navigationController,
                                                             willShow: viewController,
                                                             animated: animated)

        XCTAssertEqual(viewController, presentedViewController)
        XCTAssertEqual(animated, presentedAnimated)
    }

    func testDidShow() {
        let navigationController = UINavigationController()

        let viewController = UIViewController()
        var presentedViewController = UIViewController()

        XCTAssertNotEqual(viewController, presentedViewController)

        let animated = true
        var presentedAnimated = false

        XCTAssertNotEqual(animated, presentedAnimated)

        _ = navigationController.rx.willShow
            .subscribe(onNext: { _ in
                XCTFail("Should not be called")
            })

        _ = navigationController.rx.didShow
            .subscribe(onNext: { showEvent in
                let (viewController, animated) = showEvent
                presentedViewController = viewController
                presentedAnimated = animated
            })

        navigationController.delegate!.navigationController!(navigationController,
                                                             didShow: viewController,
                                                             animated: animated)

        XCTAssertEqual(viewController, presentedViewController)
        XCTAssertEqual(animated, presentedAnimated)
    }

}

#endif
