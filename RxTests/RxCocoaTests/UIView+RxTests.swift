//
//  UIView+RxTests.swift
//  RxTests
//
//  Created by Eduardo Barrenechea on 2015-12-06.
//
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

class UIView_RxTests: XCTestCase {

    func testSubscribeHiddenToTrue() {
        let subject = UIView()
        let hiddenSequence = Variable<Bool>(false)
        _ = hiddenSequence.subscribe(subject.rx_hidden)

        hiddenSequence.value = true
        XCTAssert(subject.hidden == true, "Expected hidden set to true")
    }

    func testSubscribeHiddenToFalse() {
        let subject = UIControl()
        let hiddenSequence = Variable<Bool>(true)
        _ = hiddenSequence.subscribe(subject.rx_hidden)

        hiddenSequence.value = false
        XCTAssert(subject.hidden == false, "Expected hidden set to false")
    }
    
}
