//
//  UIAccessibilityCustomAction+RxTests.swift
//  Tests
//
//  Created by Evan Anger on 3/20/21.
//  Copyright © 2021 Krunoslav Zaher. All rights reserved.
//

import RxCocoa
import RxSwift
import RxTest
import XCTest

final class UIAccessbilityCustomActionTests: RxTest {

}

// UIAccessbilityCustomAction
extension UIAccessbilityCustomActionTests {
    func testCustomAction_DelegateEventCompletesOnDealloc() {
        ensureEventDeallocated({ UIAccessibilityCustomAction(name: "Test") }) { (view: UIAccessibilityCustomAction) in view.rx.action }
    }
    
    func testCustomAction_actionExecution() {
        let customAction = UIAccessibilityCustomAction(name: "Test")
        var onNextCalled = false
        let disposable = customAction.rx.action.subscribe(onNext: { _ in
            onNextCalled = true
        })
        defer { disposable.dispose() }
        _ = customAction.target?.perform(customAction.selector, with: nil)
        XCTAssert(onNextCalled)
    }
}
