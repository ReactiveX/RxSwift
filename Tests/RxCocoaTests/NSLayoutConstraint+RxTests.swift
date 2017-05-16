//
//  NSLayoutConstraint+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest
#if os(macOS)
import Cocoa
typealias View = NSView
#else
import UIKit
typealias View = UIView
#endif

final class NSLayoutConstraintTest : RxTest {
}


extension NSLayoutConstraintTest {
    func testConstant_0() {
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subject2, attribute: NSLayoutAttribute.top, multiplier: 0.5, constant: 0.5)
        Observable.just(0).subscribe(constraint.rx.constant).dispose()

        XCTAssertTrue(constraint.constant == 0.0)
    }

    func testConstant_1() {
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subject2, attribute: NSLayoutAttribute.top, multiplier: 0.5, constant: 0.5)
        Observable.just(1.0).subscribe(constraint.rx.constant).dispose()

        XCTAssertTrue(constraint.constant == 1.0)
    }
}

@available(iOS 8, OSX 10.10, *)
extension NSLayoutConstraintTest {
    func testActive_True() {
        let parent = View(frame: CGRect.zero)
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        parent.addSubview(subject)
        parent.addSubview(subject2)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subject2, attribute: NSLayoutAttribute.top, multiplier: 0.5, constant: 0.5)
        Observable.just(true).subscribe(constraint.rx.active).dispose()

        XCTAssertTrue(constraint.isActive == true)
    }
    
    func testActive_False() {
        let parent = View(frame: CGRect.zero)
        let subject = View(frame: CGRect.zero)
        let subject2 = View(frame: CGRect.zero)
        parent.addSubview(subject)
        parent.addSubview(subject2)
        let constraint = NSLayoutConstraint(item: subject, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: subject2, attribute: NSLayoutAttribute.top, multiplier: 0.5, constant: 0.5)
        Observable.just(false).subscribe(constraint.rx.active).dispose()

        XCTAssertTrue(constraint.isActive == false)
    }
}
