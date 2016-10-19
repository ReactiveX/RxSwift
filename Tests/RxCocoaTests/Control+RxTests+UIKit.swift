//
//  Control+RxTests+UIKit.swift
//  Tests
//
//  Created by Ash Furrow on 4/7/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import XCTest

extension ControlTests {
    func testSubscribeEnabledToTrue() {
        let subject = UIControl()
        let disposable = Observable.just(true).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == true, "Expected enabled set to true")
    }

    func testSubscribeEnabledToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx.isEnabled)
        defer { disposable.dispose() }

        XCTAssert(subject.isEnabled == false, "Expected enabled set to false")
    }

    func testSubscribedSelectedToTrue() {
        let subject = UIControl()
        let disposable = Observable.just(true).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == true, "Expected selected set to true")
    }

    func testSubscribeSelectedToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx.isSelected)
        defer { disposable.dispose() }

        XCTAssert(subject.isSelected == false, "Expected selected set to false")
    }
}

// Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fc6820309c0>)
// Don't know why can't use ActionSheet and AlertView inside unit tests


// UIBarButtonItem
extension ControlTests {
    func testBarButtonItem_DelegateEventCompletesOnDealloc() {
        ensureEventDeallocated({ UIBarButtonItem() }) { (view: UIBarButtonItem) in view.rx.tap }
    }
}

// UILabel
extension ControlTests {
    func testLabel_HasWeakReference() {
        let variable = Variable<NSAttributedString?>(nil)
        ensureControlObserverHasWeakReference(UILabel(), { (label: UILabel) -> AnyObserver<NSAttributedString?> in label.rx.attributedText.asObserver() }, { variable.asObservable() })
    }

    func testLabel_NextElementsSetsValue() {
        let subject = UILabel()
        let attributedTextSequence = Variable<NSAttributedString?>(nil)
        let disposable = attributedTextSequence.asObservable().bindTo(subject.rx.attributedText)
        defer { disposable.dispose() }

        attributedTextSequence.value = NSAttributedString(string: "Hello!")
        XCTAssert(subject.attributedText == attributedTextSequence.value, "Expected attributedText to have been set")
    }
}

// UIProgressView
extension ControlTests {
    func testProgressView_HasWeakReference() {
        ensureControlObserverHasWeakReference(UIProgressView(), { (progressView: UIProgressView) -> AnyObserver<Float> in progressView.rx.progress.asObserver() }, { Variable<Float>(0.0).asObservable() })
    }

    func testProgressView_NextElementsSetsValue() {
        let subject = UIProgressView()
        let progressSequence = Variable<Float>(0.0)
        let disposable = progressSequence.asObservable().bindTo(subject.rx.progress)
        defer { disposable.dispose() }

        progressSequence.value = 1.0
        XCTAssert(subject.progress == progressSequence.value, "Expected progress to have been set")
    }
}

// UIControl
extension ControlTests {
    func testControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIControl = { UIControl(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UIControl) in view.rx.controlEvent(.allEditingEvents) }
    }
}

// UIGestureRecognizer
extension ControlTests {
    func testGestureRecognizer_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIGestureRecognizer = { UIGestureRecognizer(target: nil, action: NSSelectorFromString("s")) }
        ensureEventDeallocated(createView) { (view: UIGestureRecognizer) in view.rx.event }
    }
}

// UIScrollView
extension ControlTests {
    func testScrollView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIScrollView = { UIScrollView(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, CGPoint(x: 1, y: 1)) { (view: UIScrollView) in view.rx.contentOffset }
    }
}

// UISegmentedControl
extension ControlTests {
    func testSegmentedControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISegmentedControl = { UISegmentedControl(items: ["a", "b", "c"]) }
        ensurePropertyDeallocated(createView, 1) { (view: UISegmentedControl) in view.rx.value }
    }
}

// UIActivityIndicatorView
extension ControlTests {
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

// UIAlertAction
extension ControlTests {
    func testAlertAction_Enable() {
        let subject = UIAlertAction()
        Observable.just(false).subscribe(subject.rx.isEnabled).dispose()
        
        XCTAssertTrue(subject.isEnabled == false)
    }

    func testAlertAction_Disable() {
        let subject = UIAlertAction()
        Observable.just(true).subscribe(subject.rx.isEnabled).dispose()
        
        XCTAssertTrue(subject.isEnabled == true)
    }
}

#if os(iOS)

// UIDatePicker
extension ControlTests {
    func testDatePicker_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIDatePicker = { UIDatePicker(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, Date()) { (view: UIDatePicker) in view.rx.date }
    }
}


// UISlider
extension ControlTests {
    func testSlider_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISlider = { UISlider(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, 0.5) { (view: UISlider) in view.rx.value }
    }
}

// UIStepper
extension ControlTests {
    func testStepper_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIStepper = { UIStepper(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, 1) { (view: UIStepper) in view.rx.value }
    }
}

// UISwitch
extension ControlTests {
    #if swift(>=2.2)
    #else
    // TODO: UISwitch doesn't dealloc on Swift 2.3 compiler
    func testSwitch_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISwitch = { UISwitch(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, true) { (view: UISwitch) in view.rx.value }
    }
    #endif
}

// UIButton
extension ControlTests {
    func testButton_tapDeallocates() {
        let createView: () -> UIButton = { UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UIButton) in view.rx.tap }
    }
}

#elseif os(tvOS)

// UIButton
extension ControlTests {
    func testButton_tapDeallocates() {
        let createView: () -> UIButton = { UIButton(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensureEventDeallocated(createView) { (view: UIButton) in view.rx.primaryAction }
    }
}

#endif
