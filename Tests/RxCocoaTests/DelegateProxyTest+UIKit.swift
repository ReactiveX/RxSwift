//
//  DelegateProxyTest+UIKit.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 12/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift
import XCTest

// MARK: Protocols

@objc protocol UITableViewDelegateSubclass
    : UITableViewDelegate
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

@objc protocol UITableViewDataSourceSubclass
    : UITableViewDataSource
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

@objc protocol UICollectionViewDelegateSubclass
    : UICollectionViewDelegate
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

@objc protocol UICollectionViewDataSourceSubclass
    : UICollectionViewDataSource
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

@objc protocol UIScrollViewDelegateSubclass
    : UIScrollViewDelegate
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}

#if os(iOS)
@objc protocol UISearchBarDelegateSubclass
    : UISearchBarDelegate
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}
#endif

@objc protocol UITextViewDelegateSubclass
    : UITextViewDelegate
    , TestDelegateProtocol {
    optional func testEventHappened(value: Int)
}
#if os(iOS)
extension RxSearchControllerDelegateProxy: TestDelegateProtocol {
}
#endif

// MARK: Tests

// MARK: UITableView

extension DelegateProxyTest {
    func test_UITableViewDelegateExtension() {
        performDelegateTest(UITableViewSubclass1(frame: CGRect.zero))
    }

    func test_UITableViewDataSourceExtension() {
        performDelegateTest(UITableViewSubclass2(frame: CGRect.zero))
    }
}

// MARK: UICollectionView

extension DelegateProxyTest {

    func test_UICollectionViewDelegateExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass1(frame: CGRect.zero, collectionViewLayout: layout))
    }

    func test_UICollectionViewDataSourceExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass2(frame: CGRect.zero, collectionViewLayout: layout))
    }
}

// MARK: UIScrollView

extension DelegateProxyTest {
    func test_UIScrollViewDelegateExtension() {
        performDelegateTest(UIScrollViewSubclass(frame: CGRect.zero))
    }
}

// MARK: UISearchBar

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchBarDelegateExtension() {
        performDelegateTest(UISearchBarSubclass(frame: CGRect.zero))
    }
}
#endif

// MARK: UITextView

extension DelegateProxyTest {
    func test_UITextViewDelegateExtension() {
        performDelegateTest(UITextViewSubclass(frame: CGRect.zero))
    }
}

// MARK UISearchController
#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchController() {
        performDelegateTest(UISearchControllerSubclass())
    }
}
#endif
// MARK: Mocks

class ExtendTableViewDelegateProxy
    : RxTableViewDelegateProxy
    , UITableViewDelegateSubclass {
    weak private(set) var control: UITableViewSubclass1?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITableViewSubclass1)
        super.init(parentObject: parentObject)
    }
}

class UITableViewSubclass1
    : UITableView
    , TestDelegateControl {
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendTableViewDelegateProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}

class ExtendTableViewDataSourceProxy
    : RxTableViewDataSourceProxy
    , UITableViewDelegateSubclass {
    weak private(set) var control: UITableViewSubclass2?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITableViewSubclass2)
        super.init(parentObject: parentObject)
    }
}

class UITableViewSubclass2
    : UITableView
    , TestDelegateControl {
    override func rx_createDataSourceProxy() -> RxTableViewDataSourceProxy {
        return ExtendTableViewDataSourceProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (dataSource as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_dataSource
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}

class ExtendCollectionViewDelegateProxy
    : RxCollectionViewDelegateProxy
    , UITableViewDelegateSubclass {
    weak private(set) var control: UICollectionViewSubclass1?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UICollectionViewSubclass1)
        super.init(parentObject: parentObject)
    }
}

class UICollectionViewSubclass1
    : UICollectionView
    , TestDelegateControl {
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendCollectionViewDelegateProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}

class ExtendCollectionViewDataSourceProxy
    : RxCollectionViewDataSourceProxy
    , UICollectionViewDelegateSubclass {
    weak private(set) var control: UICollectionViewSubclass2?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UICollectionViewSubclass2)
        super.init(parentObject: parentObject)
    }
}

class UICollectionViewSubclass2
    : UICollectionView
    , TestDelegateControl {
    override func rx_createDataSourceProxy() -> RxCollectionViewDataSourceProxy {
        return ExtendCollectionViewDataSourceProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (dataSource as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_dataSource
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}

class ExtendScrollViewDelegateProxy
    : RxScrollViewDelegateProxy
    , UIScrollViewDelegateSubclass {
    weak private(set) var control: UIScrollViewSubclass?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UIScrollViewSubclass)
        super.init(parentObject: parentObject)
    }
}

class UIScrollViewSubclass
    : UIScrollView
    , TestDelegateControl {
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendScrollViewDelegateProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}

#if os(iOS)
class ExtendSearchBarDelegateProxy
    : RxSearchBarDelegateProxy
    , UISearchBarDelegateSubclass {
    weak private(set) var control: UISearchBarSubclass?
    
    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UISearchBarSubclass)
        super.init(parentObject: parentObject)
    }
}

class UISearchBarSubclass
    : UISearchBar
    , TestDelegateControl {
    
    override func rx_createDelegateProxy() -> RxSearchBarDelegateProxy {
        return ExtendSearchBarDelegateProxy(parentObject: self)
    }
    
    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}
#endif

class ExtendTextViewDelegateProxy
    : RxTextViewDelegateProxy
    , UITextViewDelegateSubclass {
    weak private(set) var control: UITextViewSubclass?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITextViewSubclass)
        super.init(parentObject: parentObject)
    }
}

class UITextViewSubclass
    : UITextView
    , TestDelegateControl {
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendTextViewDelegateProxy(parentObject: self)
    }

    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}
#if os(iOS)
class UISearchControllerSubclass
    : UISearchController
    , TestDelegateControl {

    func doThatTest(value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var test: Observable<Int> {
        return rx_delegate
            .observe(#selector(TestDelegateProtocol.testEventHappened(_:)))
            .map { a in (a[0] as! NSNumber).integerValue }
    }
}
#endif
