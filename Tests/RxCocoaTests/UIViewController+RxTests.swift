//
//  UIViewController+RxTests.swift
//  Tests
//
//  Created by Kyle Fuller on 30/05/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import UIKit
import XCTest

final class UIViewControllerTests : RxTest {
}

extension UIViewControllerTests {
  func testRxTitle() {
    let viewController = UIViewController()

    _ = Observable.just("title").bind(to: viewController.rx.title)

    XCTAssertEqual("title", viewController.title)
  }
}
