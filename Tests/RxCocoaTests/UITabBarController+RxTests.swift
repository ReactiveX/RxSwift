//
//  UITabBarController+RxTests.swift
//  Tests
//
//  Created by Yusuke Kita on 2016/12/07.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UITabBarControllerTests: RxTest {
    let createSubject: () -> UITabBarController = { UITabBarController() }
}

/**
 iOS only
 */
#if os(iOS)
extension UITabBarControllerTests {
    func testWillBeginCustomizing() {
        let subject = createSubject()
        
        let viewControllers = [UIViewController()]
        var returnedViewControllers = [UIViewController]()
        
        XCTAssertNotEqual(returnedViewControllers, viewControllers)
        
        _ = subject.rx.willBeginCustomizing
            .subscribe(onNext: { vc in
                returnedViewControllers = vc
            })
        
        subject.delegate!.tabBarController!(subject, willBeginCustomizing: viewControllers)
        
        XCTAssertEqual(returnedViewControllers, viewControllers)
    }
    
    func testWillEndCustomizing() {
        let subject = createSubject()
        
        let viewControllers = [UIViewController()]
        var returnedViewControllers = [UIViewController]()
        var changed: Bool!
        
        XCTAssertNotEqual(returnedViewControllers, viewControllers)
        XCTAssertNotEqual(changed, true)
        
        _ = subject.rx.willEndCustomizing
            .subscribe(onNext: { value in
                let (vc, c) = value
                returnedViewControllers = vc
                changed = c
            })
        
        subject.delegate!.tabBarController!(subject, willEndCustomizing: viewControllers, changed: true)
        
        XCTAssertEqual(returnedViewControllers, viewControllers)
        XCTAssertEqual(changed, true)
    }
    
    func testDidEndCustomizing() {
        let subject = createSubject()
        
        let viewControllers = [UIViewController()]
        var returnedViewControllers = [UIViewController]()
        var changed: Bool!
        
        XCTAssertNotEqual(returnedViewControllers, viewControllers)
        XCTAssertNotEqual(changed, true)
        
        _ = subject.rx.didEndCustomizing
            .subscribe(onNext: { value in
                let (vc, c) = value
                returnedViewControllers = vc
                changed = c
            })
        
        subject.delegate!.tabBarController!(subject, didEndCustomizing: viewControllers, changed: true)
        
        XCTAssertEqual(returnedViewControllers, viewControllers)
        XCTAssertEqual(changed, true)
    }
}
#endif

/**
 iOS and tvOS
 */
extension UITabBarControllerTests {
    func testDidSelect() {
        let subject = createSubject()
        
        let viewController = UIViewController()
        var returnedViewController = UIViewController()
        
        XCTAssertNotEqual(returnedViewController, viewController)
        
        _ = subject.rx.didSelect
            .subscribe(onNext: { vc in
                returnedViewController = vc
            })
        
        subject.delegate!.tabBarController!(subject, didSelect: viewController)
        
        XCTAssertEqual(returnedViewController, viewController)
    }
}
#endif
