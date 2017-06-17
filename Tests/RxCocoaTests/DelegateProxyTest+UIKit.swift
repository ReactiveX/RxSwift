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

extension DelegateProxyTest {
    func test_UITableViewDelegateExtension() {
        performDelegateTest(UITableViewSubclass1(frame: CGRect.zero))
    }

    func test_UITableViewDataSourceExtension() {
        performDelegateTest(UITableViewSubclass2(frame: CGRect.zero))
    }
}

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

extension DelegateProxyTest {
    func test_UINavigationControllerDelegateExtension() {
        performDelegateTest(UINavigationControllerSubclass())
    }
}

extension DelegateProxyTest {
    func test_UIScrollViewDelegateExtension() {
        performDelegateTest(UIScrollViewSubclass1(frame: CGRect.zero))
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchBarDelegateExtension() {
        performDelegateTest(UISearchBarSubclass(frame: CGRect.zero))
    }
}
#endif

extension DelegateProxyTest {
    func test_UITextViewDelegateExtension() {
        performDelegateTest(UITextViewSubclass(frame: CGRect.zero))
    }
}

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

#if os(iOS)
extension DelegateProxyTest {
    func test_UIWebViewDelegateExtension() {
        performDelegateTest(UIWebViewSubclass(frame: CGRect.zero))
    }
}
#endif

extension DelegateProxyTest {
    func test_UITabBarControllerDelegateExtension() {
        performDelegateTest(UITabBarControllerSubclass())
    }
}

extension DelegateProxyTest {
    func test_UITabBarDelegateExtension() {
        performDelegateTest(UITabBarSubclass())
    }
}

extension DelegateProxyTest {
    func test_DelegateProxyExtendOrder() {
        performDelegateTest(UIScrollViewSubclass2(frame: CGRect.zero))
    }
}

extension DelegateProxyTest {
    func test_DelegateProxyHasNoSpecificFactory() {
        performDelegateTest(UIScrollViewSubclass3(frame: CGRect.zero))
    }
}

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
    weak fileprivate(set) var control: UIScrollViewSubclass1?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UIScrollViewSubclass1)
        super.init(parentObject: parentObject)
    }
}

class UIScrollViewSubclass1
    : UIScrollView
    , TestDelegateControl {
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

final class ExtendScrollViewDelegateProxy2
    : RxScrollViewDelegateProxy
, TestDelegateProtocol {
    weak fileprivate(set) var control: UIScrollViewSubclass2?
    
    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UIScrollViewSubclass2)
        super.init(parentObject: parentObject)
    }
}

final class UIScrollViewSubclass2
    : UIScrollView
, TestDelegateControl {
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

final class UIScrollViewSubclass3: UIScrollViewSubclass1 {
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

final class ExtendNavigationControllerDelegateProxy
    : RxNavigationControllerDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UINavigationControllerSubclass?

    required init(parentObject: AnyObject) {
        self.control = (parentObject as! UINavigationControllerSubclass)
        super.init(parentObject: parentObject)
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

final class UINavigationControllerSubclass: UINavigationController, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: TestDelegateProtocol) -> Disposable {
        return RxNavigationControllerDelegateProxy.installForwardDelegate(testDelegate,
                                                                          retainDelegate: false,
                                                                          onProxyForObject: self)
    }
}

final class UITabBarControllerSubclass
    : UITabBarController
    , TestDelegateControl {
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
