//
//  Control+RxTests+UIKit.swift
//  RxTests
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
        let disposable = Observable.just(true).subscribe(subject.rx_enabled)
        defer { disposable.dispose() }

        XCTAssert(subject.enabled == true, "Expected enabled set to true")
    }

    func testSubscribeEnabledToFalse() {
        let subject = UIControl()
        let disposable = Observable.just(false).subscribe(subject.rx_enabled)
        defer { disposable.dispose() }

        XCTAssert(subject.enabled == false, "Expected enabled set to false")
    }
}

// UITextField
extension ControlTests {
    func testTextField_TextCompletesOnDealloc() {
        ensurePropertyDeallocated({ UITextField() }, "a") { (view: UITextField) in view.rx_text }
    }
}

// Attempting to load the view of a view controller while it is deallocating is not allowed and may result in undefined behavior (<UIAlertController: 0x7fc6820309c0>)
// Don't know why can't use ActionSheet and AlertView inside unit tests


// UIBarButtonItem
extension ControlTests {
    func testBarButtonItem_DelegateEventCompletesOnDealloc() {
        ensureEventDeallocated({ UIBarButtonItem() }) { (view: UIBarButtonItem) in view.rx_tap }
    }
}

// UICollectionView
extension ControlTests {
    func testCollectionView_DelegateEventCompletesOnDealloc() {
        let layout = UICollectionViewFlowLayout()
        let createView: () -> UICollectionView = { UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout) }

        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_itemSelected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelSelected(Int.self) }
    }

    func testCollectionView_DelegateEventCompletesOnDealloc1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            let s = items.bindTo(collectionView.rx_itemsWithCellFactory) { (cv, index: Int, item: Int) -> UICollectionViewCell in
                return UICollectionViewCell(frame: CGRectMake(1, 1, 1, 1))
            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelSelected(Int.self) }
    }

    func testCollectionView_DelegateEventCompletesOnDealloc2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            collectionView.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let s = items.bindTo(collectionView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelSelected(Int.self) }
    }

    func testCollectionView_DelegateEventCompletesOnDealloc2_cellType() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            collectionView.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let s = items.bindTo(collectionView.rx_itemsWithCellIdentifier("a", cellType: UICollectionViewCell.self)) { (index: Int, item: Int, cell) in

            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelSelected(Int.self) }
    }

    func testCollectionView_ModelSelected1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            let s = items.bindTo(collectionView.rx_itemsWithCellFactory) { (cv, index: Int, item: Int) -> UICollectionViewCell in
                return UICollectionViewCell(frame: CGRectMake(1, 1, 1, 1))
            }

            return (collectionView, s)
        }

        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx_modelSelected(Int.self)
            .subscribeNext { (item: Int) in
                selectedItem = item
            }

        collectionView.delegate!.collectionView!(collectionView, didSelectItemAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testCollectionView_ModelSelected2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            collectionView.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(collectionView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx_modelSelected(Int.self)
            .subscribeNext { item in
                selectedItem = item
            }

        collectionView.delegate!.collectionView!(collectionView, didSelectItemAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)
        
        s.dispose()
        dataSourceSubscription.dispose()
    }
}

// UILabel
extension ControlTests {
    func testLabel_HasWeakReference() {
        let variable = Variable<NSAttributedString?>(nil)
        ensureControlObserverHasWeakReference(UILabel(), { (label: UILabel) -> AnyObserver<NSAttributedString?> in label.rx_attributedText }, { variable.asObservable() })
    }

    func testLabel_NextElementsSetsValue() {
        let subject = UILabel()
        let attributedTextSequence = Variable<NSAttributedString?>(nil)
        let disposable = attributedTextSequence.subscribe(subject.rx_attributedText)
        defer { disposable.dispose() }

        attributedTextSequence.value = NSAttributedString(string: "Hello!")
        XCTAssert(subject.attributedText == attributedTextSequence.value, "Expected attributedText to have been set")
    }
}

// UITableView
extension ControlTests {
    func testTableView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UITableView = { UITableView(frame: CGRectMake(0, 0, 1, 1)) }

        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemSelected }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemDeleted }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemMoved }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemInserted }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_DelegateEventCompletesOnDealloc1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellFactory) { (tv, index: Int, item: Int) -> UITableViewCell in
                return UITableViewCell(style: .Default, reuseIdentifier: "Identity")
            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_DelegateEventCompletesOnDealloc2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_DelegateEventCompletesOnDealloc2_cellType() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a", cellType: UITableViewCell.self)) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_ModelSelected1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellFactory) { (tv, index: Int, item: Int) -> UITableViewCell in
                return UITableViewCell(style: .Default, reuseIdentifier: "Identity")
            }

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil
        
        let s = tableView.rx_modelSelected(Int.self)
            .subscribeNext { item in
                selectedItem = item
            }

        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testTableView_ModelSelected2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = tableView.rx_modelSelected(Int.self)
            .subscribeNext { item in
                selectedItem = item
        }

        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }
}

// UIControl
extension ControlTests {
    func testControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIControl = { UIControl(frame: CGRectMake(0, 0, 1, 1)) }
        ensureEventDeallocated(createView) { (view: UIControl) in view.rx_controlEvent(.AllEditingEvents) }
    }
}

// UIGestureRecognizer
extension ControlTests {
    func testGestureRecognizer_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIGestureRecognizer = { UIGestureRecognizer(target: nil, action: "s") }
        ensureEventDeallocated(createView) { (view: UIGestureRecognizer) in view.rx_event }
    }
}

// UIScrollView
extension ControlTests {
    func testScrollView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIScrollView = { UIScrollView(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, CGPoint(x: 1, y: 1)) { (view: UIScrollView) in view.rx_contentOffset }
    }
}

// UISegmentedControl
extension ControlTests {
    func testSegmentedControl_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISegmentedControl = { UISegmentedControl(items: ["a", "b", "c"]) }
        ensurePropertyDeallocated(createView, 1) { (view: UISegmentedControl) in view.rx_value }
    }
}

// UITextView
extension ControlTests {
    func testText_DelegateEventCompletesOnDealloc() {
        let createView: () -> UITextView = { UITextView(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, "text") { (view: UITextView) in view.rx_text }
    }
}

// UIActivityIndicatorView
extension ControlTests {
    func testActivityIndicator_HasWeakReference() {
        ensureControlObserverHasWeakReference(UIActivityIndicatorView(), { (view: UIActivityIndicatorView) -> AnyObserver<Bool> in view.rx_animating }, { Variable<Bool>(true).asObservable() })
    }

    func testActivityIndicator_NextElementsSetsValue() {
        let subject = UIActivityIndicatorView()
        let boolSequence = Variable<Bool>(false)

        let disposable = boolSequence.subscribe(subject.rx_animating)
        defer { disposable.dispose() }

        boolSequence.value = true
        XCTAssertTrue(subject.isAnimating(), "Expected animation to be started")

        boolSequence.value = false
        XCTAssertFalse(subject.isAnimating(), "Expected animation to be stopped")
    }
}


#if os(iOS)

// UIActionSheet
extension ControlTests {
    func testActionSheet_DelegateEventCompletesOnDealloc() {
        let createActionSheet: () -> UIActionSheet = { UIActionSheet(title: "", delegate: nil, cancelButtonTitle: "", destructiveButtonTitle: "") }
        ensureEventDeallocated(createActionSheet) { (view: UIActionSheet) in view.rx_clickedButtonAtIndex }
        ensureEventDeallocated(createActionSheet) { (view: UIActionSheet) in view.rx_didDismissWithButtonIndex }
        ensureEventDeallocated(createActionSheet) { (view: UIActionSheet) in view.rx_willDismissWithButtonIndex }
    }
}

// UIAlertView
extension ControlTests {
    func testAlertView_DelegateEventCompletesOnDealloc() {
        let createAlertView: () -> UIAlertView = { UIAlertView(title: "", message: "", delegate: nil, cancelButtonTitle: nil) }
        ensureEventDeallocated(createAlertView) { (view: UIAlertView) in view.rx_clickedButtonAtIndex }
        ensureEventDeallocated(createAlertView) { (view: UIAlertView) in view.rx_didDismissWithButtonIndex }
        ensureEventDeallocated(createAlertView) { (view: UIAlertView) in view.rx_willDismissWithButtonIndex }
    }
}

// UIDatePicker
extension ControlTests {
    func testDatePicker_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIDatePicker = { UIDatePicker(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, NSDate()) { (view: UIDatePicker) in view.rx_date }
    }
}


// UISlider
extension ControlTests {
    func testSlider_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISlider = { UISlider(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, 0.5) { (view: UISlider) in view.rx_value }
    }
}

// UIStepper
extension ControlTests {
    func testStepper_DelegateEventCompletesOnDealloc() {
        let createView: () -> UIStepper = { UIStepper(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, 1) { (view: UIStepper) in view.rx_value }
    }
}

// UISwitch
extension ControlTests {
    func testSwitch_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISwitch = { UISwitch(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, true) { (view: UISwitch) in view.rx_value }
    }
}

// UISearchBar
extension ControlTests {
    func testSearchBar_DelegateEventCompletesOnDealloc() {
        let createView: () -> UISearchBar = { UISearchBar(frame: CGRectMake(0, 0, 1, 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: UISearchBar) in view.rx_text }
    }
}


// UIButton
extension ControlTests {
    func testButton_tapDeallocates() {
        let createView: () -> UIButton = { UIButton(frame: CGRectMake(0, 0, 1, 1)) }
        ensureEventDeallocated(createView) { (view: UIButton) in view.rx_tap }
    }
}

#elseif os(tvOS)

// UIButton
extension ControlTests {
    func testButton_tapDeallocates() {
        let createView: () -> UIButton = { UIButton(frame: CGRectMake(0, 0, 1, 1)) }
        ensureEventDeallocated(createView) { (view: UIButton) in view.rx_primaryAction }
    }
}

#endif
