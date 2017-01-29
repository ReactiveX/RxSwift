//
//  UIActivityIndicatorView+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 11/26/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UIActivityIndicatorViewTests: RxTest {

}

extension UIActivityIndicatorViewTests {
    func testActivityIndicator_HasWeakReference() {
        ensureControlObserverHasWeakReference(UIActivityIndicatorView(), { (view: UIActivityIndicatorView) -> AnyObserver<Bool> in view.rx.isAnimating.asObserver() }, { Variable<Bool>(true).asObservable() })
    }

    func testActivityIndicator_NextElementsSetsValue() {
        let subject = UIActivityIndicatorView()
        let boolSequence = Variable<Bool>(false)

        let disposable = boolSequence.asObservable().bindTo(subject.rx.isAnimating)
        defer { disposable.dispose() }

        boolSequence.value = true
        XCTAssertTrue(subject.isAnimating, "Expected animation to be started")

        boolSequence.value = false
        XCTAssertFalse(subject.isAnimating, "Expected animation to be stopped")
    }
}
