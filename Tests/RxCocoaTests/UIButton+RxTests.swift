//
//  UIButton+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 6/24/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxTest
import RxCocoa
import UIKit
import RxSwift
import XCTest

final class UIButtonTests: RxTest {
}

extension UIButtonTests {
    func testTitleNormal() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: .normal) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title(for: .normal))
        XCTAssertTrue(button.title(for: .normal) == "normal")
    }

    func testTitleSelected() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: .selected) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title(for: .selected))
        XCTAssertTrue(button.title(for: .selected) == "normal")
    }

    func testTitleDefault() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))

        XCTAssertFalse(button.title(for: []) == "normal")
        _ = Observable.just("normal").subscribe(button.rx.title())
        XCTAssertTrue(button.title(for: []) == "normal")
    }
    
    func testAttributedTitleNormal() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        XCTAssertFalse(button.attributedTitle(for: []) == NSAttributedString(string: "normal"))
        _ = Observable.just(NSAttributedString(string: "normal")).subscribe(button.rx.attributedTitle(for: []))
        XCTAssertTrue(button.attributedTitle(for: []) == NSAttributedString(string: "normal"))
    }
    
    func testAttributedTitleSelected() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        XCTAssertFalse(button.attributedTitle(for: .selected) == NSAttributedString(string: "normal"))
        _ = Observable.just(NSAttributedString(string: "normal")).subscribe(button.rx.attributedTitle(for: .selected))
        XCTAssertTrue(button.attributedTitle(for: .selected) == NSAttributedString(string: "normal"))
    }
    
    func testAttributedTitleDefault() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        XCTAssertFalse(button.attributedTitle(for: []) == NSAttributedString(string: "normal"))
        _ = Observable.just(NSAttributedString(string: "normal")).subscribe(button.rx.attributedTitle())
        XCTAssertTrue(button.attributedTitle(for: []) == NSAttributedString(string: "normal"))
    }
}

#if os(iOS)

    extension UIButtonTests {
        func testButton_tapDeallocates() {
            let createView: () -> UIButton = { UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensureEventDeallocated(createView) { (view: UIButton) in view.rx.tap }
        }

        func testImageNormal() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.image(for: .normal) == image)
            _ = Observable.just(image).subscribe(button.rx.image(for: .normal))
            XCTAssertTrue(button.image(for: .normal) == image)
        }

        func testImageSelected() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.image(for: .selected) == image)
            _ = Observable.just(image).subscribe(button.rx.image(for: .selected))
            XCTAssertTrue(button.image(for: .selected) == image)
        }

        func testImageDefault() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.image(for: []) == image)
            _ = Observable.just(image).subscribe(button.rx.image())
            XCTAssertTrue(button.image(for: []) == image)
        }

        func testBackgroundImageNormal() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.backgroundImage(for: .normal) == image)
            _ = Observable.just(image).subscribe(button.rx.backgroundImage(for: .normal))
            XCTAssertTrue(button.backgroundImage(for: .normal) == image)
        }

        func testBackgroundImageSelected() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.backgroundImage(for: .selected) == image)
            _ = Observable.just(image).subscribe(button.rx.backgroundImage(for: .selected))
            XCTAssertTrue(button.backgroundImage(for: .selected) == image)
        }

        func testBackgroundImageDefault() {
            let button = UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            let image = UIImage()

            XCTAssertFalse(button.backgroundImage(for: []) == image)
            _ = Observable.just(image).subscribe(button.rx.backgroundImage())
            XCTAssertTrue(button.backgroundImage(for: []) == image)
        }
    }

#endif

#if os(tvOS)

    // UIButton
    extension UIButtonTests {
        func testButton_tapDeallocates() {
            let createView: () -> UIButton = { UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
            ensureEventDeallocated(createView) { (view: UIButton) in view.rx.primaryAction }
        }
    }

#endif
