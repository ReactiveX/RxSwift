//
//  DelegateProxyTest+UIKit.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import UIKit
@testable import RxCocoa
@testable import RxSwift
import XCTest


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
    
extension DelegateProxyTest {
    func test_UIPickerViewExtension() {
        performDelegateTest(UIPickerViewSubclass(frame: CGRect.zero))
    }
}
#endif

// MARK: UIWebView
#if os(iOS)
extension DelegateProxyTest {
    func test_UIWebViewDelegateExtension() {
        performDelegateTest(UIWebViewSubclass(frame: CGRect.zero))
    }
}
#endif

// MARK: UITabBarController

extension DelegateProxyTest {
    func test_UITabBarControllerDelegateExtension() {
        performDelegateTest(UITabBarControllerSubclass())
    }
}

// MARK: UITabBar

extension DelegateProxyTest {
    func test_UITabBarDelegateExtension() {
        performDelegateTest(UITabBarSubclass())
    }
}

// MARK: NSTextStorage

extension DelegateProxyTest {
    /* something is wrong with subclassing mechanism.
    func test_NSTextStorageDelegateExtension() {
        performDelegateTest(NSTextStorageSubclass(attributedString: NSAttributedString()))
    }*/
}

// MARK: Mocks

final class ExtendTableViewDelegateProxy
    : RxTableViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass1?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITableViewSubclass1)
        super.init(parentObject: parentObject)
    }
}

final class UITableViewSubclass1
    : UITableView
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendTableViewDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendTableViewDataSourceProxy
    : RxTableViewDataSourceProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass2?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITableViewSubclass2)
        super.init(parentObject: parentObject)
    }
}

final class UITableViewSubclass2
    : UITableView
    , TestDelegateControl {
    override func createRxDataSourceProxy() -> RxTableViewDataSourceProxy {
        return ExtendTableViewDataSourceProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        if dataSource != nil {
            (dataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDelegateProxy
    : RxCollectionViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass1?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UICollectionViewSubclass1)
        super.init(parentObject: parentObject)
    }
}

final class UICollectionViewSubclass1
    : UICollectionView
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendCollectionViewDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDataSourceProxy
    : RxCollectionViewDataSourceProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass2?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UICollectionViewSubclass2)
        super.init(parentObject: parentObject)
    }
}

final class UICollectionViewSubclass2
    : UICollectionView
    , TestDelegateControl {
    override func createRxDataSourceProxy() -> RxCollectionViewDataSourceProxy {
        return ExtendCollectionViewDataSourceProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        if dataSource != nil {
            (dataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxCollectionViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendScrollViewDelegateProxy
    : RxScrollViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIScrollViewSubclass?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UIScrollViewSubclass)
        super.init(parentObject: parentObject)
    }
}

final class UIScrollViewSubclass
    : UIScrollView
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendScrollViewDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

#if os(iOS)
final class ExtendSearchBarDelegateProxy
    : RxSearchBarDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UISearchBarSubclass?
    
    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UISearchBarSubclass)
        super.init(parentObject: parentObject)
    }
}

final class UISearchBarSubclass
    : UISearchBar
    , TestDelegateControl {
    
    override func createRxDelegateProxy() -> RxSearchBarDelegateProxy {
        return ExtendSearchBarDelegateProxy(parentObject: self)
    }
    
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxSearchBarDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#endif

final class ExtendTextViewDelegateProxy
    : RxTextViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITextViewSubclass?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITextViewSubclass)
        super.init(parentObject: parentObject)
    }
}

final class UITextViewSubclass
    : UITextView
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxScrollViewDelegateProxy {
        return ExtendTextViewDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#if os(iOS)
final class ExtendSearchControllerDelegateProxy
    : RxSearchControllerDelegateProxy
    , TestDelegateProtocol {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}

final class UISearchControllerSubclass
    : UISearchController
    , TestDelegateControl {

    override func createRxDelegateProxy() -> RxSearchControllerDelegateProxy {
        return ExtendSearchControllerDelegateProxy(parentObject: self)
    }
    
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxSearchControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}


final class ExtendPickerViewDelegateProxy
    : RxPickerViewDelegateProxy
    , TestDelegateProtocol {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}
    
final class UIPickerViewSubclass
    : UIPickerView
    , TestDelegateControl {

    public override func createRxDelegateProxy() -> RxPickerViewDelegateProxy {
        return ExtendPickerViewDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxPickerViewDelegateProxy.installForwardDelegate(testDelegate,
                                                                retainDelegate: false,
                                                                onProxyForObject: self)
    }
}

final class ExtendWebViewDelegateProxy
    : RxWebViewDelegateProxy
    , TestDelegateProtocol {
    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}

final class UIWebViewSubclass: UIWebView, TestDelegateControl {

    override func createRxDelegateProxy() -> RxWebViewDelegateProxy {
        return ExtendWebViewDelegateProxy(parentObject: self)
    }
    
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxWebViewDelegateProxy.installForwardDelegate(testDelegate,
                                                             retainDelegate: false,
                                                             onProxyForObject: self)
    }
    
}

#endif



final class ExtendTextStorageDelegateProxy
    : RxTextStorageDelegateProxy
    , TestDelegateProtocol {

    required init(parentObject: AnyObject) {
        super.init(parentObject: parentObject)
    }
}

final class NSTextStorageSubclass
    : NSTextStorage
    , TestDelegateControl {

    override func createRxDelegateProxy() -> RxTextStorageDelegateProxy {
        return ExtendTextStorageDelegateProxy(parentObject: self)
    }

    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}



final class ExtendTabBarControllerDelegateProxy
    : RxTabBarControllerDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarControllerSubclass?
    
    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITabBarControllerSubclass)
        super.init(parentObject: parentObject)
    }
}

final class ExtendTabBarDelegateProxy
    : RxTabBarDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarSubclass?
    
    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UITabBarSubclass)
        super.init(parentObject: parentObject)
    }
}

final class UITabBarControllerSubclass
    : UITabBarController
    , TestDelegateControl {
    override func createRxDelegateProxy() -> RxTabBarControllerDelegateProxy {
        return ExtendTabBarControllerDelegateProxy(parentObject: self)
    }
    
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxTabBarControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class UITabBarSubclass: UITabBar, TestDelegateControl {
    override func createRxDelegateProxy() -> RxTabBarDelegateProxy {
        return ExtendTabBarDelegateProxy(parentObject: self)
    }
    
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxTabBarDelegateProxy.installForwardDelegate(testDelegate,
                                                            retainDelegate: false,
                                                            onProxyForObject: self)
    }
}
