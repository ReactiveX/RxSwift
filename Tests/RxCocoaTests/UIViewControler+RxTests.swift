//
//  UIViewControler+RxTests.swift
//  Rx
//
//  Created by Kyle Fuller on 30/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import UIKit
import XCTest

class UITViewControllerTests : RxTest {
  func testRxTitle() {
    let viewController = UIViewController()

    _ = Observable.just("title").bindTo(viewController.rx_title)

    XCTAssertEqual("title", viewController.title)
  }
}