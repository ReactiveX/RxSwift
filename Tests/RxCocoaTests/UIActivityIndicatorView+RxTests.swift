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
import RxRelay
import XCTest

final class UIActivityIndicatorViewTests: RxTest {

}

extension UIActivityIndicatorViewTests {
    func testActivityIndicator_HasWeakReference() {
        ensureControlObserverHasWeakReference(UIActivityIndicatorView(), { (view: UIActivityIndicatorView) -> AnyObserver<Bool> in view.rx.isAnimating.asObserver() }, { BehaviorRelay<Bool>(value: true).asObservable() })
    }

    func testActivityIndicator_NextElementsSetsValue() {
        let subject = UIActivityIndicatorView()
        let boolSequence = BehaviorRelay<Bool>(value: false)

        let disposable = boolSequence.asObservable().bind(to: subject.rx.isAnimating)
        defer { disposable.dispose() }

        boolSequence.accept(true)
        XCTAssertTrue(subject.isAnimating, "Expected animation to be started")

        boolSequence.accept(false)
        XCTAssertFalse(subject.isAnimating, "Expected animation to be stopped")
    }
}
