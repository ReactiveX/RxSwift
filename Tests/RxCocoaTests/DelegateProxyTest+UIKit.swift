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
        performDelegateTest(UITableViewSubclass1(frame: CGRect.zero), proxyType: ExtendTableViewDelegateProxy.self)
    }

    func test_UITableViewDataSourceExtension() {
        performDelegateTest(UITableViewSubclass2(frame: CGRect.zero), proxyType: ExtendTableViewDataSourceProxy.self)
    }
}

extension DelegateProxyTest {

    func test_UICollectionViewDelegateExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass1(frame: CGRect.zero, collectionViewLayout: layout), proxyType: ExtendCollectionViewDelegateProxy.self)
    }

    func test_UICollectionViewDataSourceExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass2(frame: CGRect.zero, collectionViewLayout: layout), proxyType: ExtendCollectionViewDataSourceProxy.self)
    }
}

extension DelegateProxyTest {
    func test_UINavigationControllerDelegateExtension() {
        performDelegateTest(UINavigationControllerSubclass(), proxyType: ExtendNavigationControllerDelegateProxy.self)
    }
}

extension DelegateProxyTest {
    func test_UIScrollViewDelegateExtension() {
        performDelegateTest(UIScrollViewSubclass(frame: CGRect.zero), proxyType: ExtendScrollViewDelegateProxy.self)
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchBarDelegateExtension() {
        performDelegateTest(UISearchBarSubclass(frame: CGRect.zero), proxyType: ExtendSearchBarDelegateProxy.self)
    }
}
#endif

extension DelegateProxyTest {
    func test_UITextViewDelegateExtension() {
        performDelegateTest(UITextViewSubclass(frame: CGRect.zero), proxyType: ExtendTextViewDelegateProxy.self)
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchController() {
        performDelegateTest(UISearchControllerSubclass(), proxyType: ExtendSearchControllerDelegateProxy.self)
    }
}
    
extension DelegateProxyTest {
    func test_UIPickerViewExtension() {
        performDelegateTest(UIPickerViewSubclass(frame: CGRect.zero), proxyType: ExtendPickerViewDelegateProxy.self)
    }
    
    func test_UIPickerViewDataSourceExtension() {
        performDelegateTest(UIPickerViewSubclass2(frame: CGRect.zero), proxyType: ExtendPickerViewDataSourceProxy.self)
    }
}
#endif

#if os(iOS)
extension DelegateProxyTest {
    func test_UIWebViewDelegateExtension() {
        performDelegateTest(UIWebViewSubclass(frame: CGRect.zero), proxyType: ExtendWebViewDelegateProxy.self)
    }
}
#endif

extension DelegateProxyTest {
    func test_UITabBarControllerDelegateExtension() {
        performDelegateTest(UITabBarControllerSubclass(), proxyType: ExtendTabBarControllerDelegateProxy.self)
    }
}

extension DelegateProxyTest {
    func test_UITabBarDelegateExtension() {
        performDelegateTest(UITabBarSubclass(), proxyType: ExtendTabBarDelegateProxy.self)
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
    : RxTableViewDelegateProxy<UITableViewSubclass1>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass1?

    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UITableViewSubclass1
    : UITableView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UITableViewSubclass1, UIScrollViewDelegate> {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendTableViewDataSourceProxy
    : RxTableViewDataSourceProxy<UITableViewSubclass2>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass2?

    required init(parentObject: ParentObject) {
        self.control = parentObject
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

    var delegateProxy: DelegateProxy<UITableViewSubclass2, UITableViewDataSource> {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UITableViewDataSource) -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDelegateProxy
    : RxCollectionViewDelegateProxy<UICollectionViewSubclass1>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass1?

    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UICollectionViewSubclass1
    : UICollectionView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UICollectionViewSubclass1, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDataSourceProxy
    : RxCollectionViewDataSourceProxy<UICollectionViewSubclass2>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass2?

    required init(parentObject: ParentObject) {
        self.control = parentObject
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

    var delegateProxy: DelegateProxy<UICollectionViewSubclass2, UICollectionViewDataSource> {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UICollectionViewDataSource) -> Disposable {
        return RxCollectionViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendScrollViewDelegateProxy
    : RxScrollViewDelegateProxy<UIScrollViewSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIScrollViewSubclass?

    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UIScrollViewSubclass
    : UIScrollView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollViewSubclass, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

#if os(iOS)
final class ExtendSearchBarDelegateProxy
    : RxSearchBarDelegateProxy<UISearchBarSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UISearchBarSubclass?
    
    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UISearchBarSubclass
    : UISearchBar
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UISearchBarSubclass, UISearchBarDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchBarDelegate) -> Disposable {
        return RxSearchBarDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#endif

final class ExtendTextViewDelegateProxy
    : RxTextViewDelegateProxy<UITextViewSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITextViewSubclass?

    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UITextViewSubclass
    : UITextView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UITextViewSubclass, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#if os(iOS)
final class ExtendSearchControllerDelegateProxy
    : RxSearchControllerDelegateProxy<UISearchControllerSubclass>
    , TestDelegateProtocol {
    required init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class UISearchControllerSubclass
    : UISearchController
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UISearchControllerSubclass, UISearchControllerDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchControllerDelegate) -> Disposable {
        return RxSearchControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}


final class ExtendPickerViewDelegateProxy
    : RxPickerViewDelegateProxy<UIPickerViewSubclass>
    , TestDelegateProtocol {
    required init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}
    
final class UIPickerViewSubclass
    : UIPickerView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UIPickerViewSubclass, UIPickerViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIPickerViewDelegate) -> Disposable {
        return RxPickerViewDelegateProxy.installForwardDelegate(testDelegate,
                                                                retainDelegate: false,
                                                                onProxyForObject: self)
    }
}
    
final class ExtendPickerViewDataSourceProxy
    : RxPickerViewDataSourceProxy<UIPickerViewSubclass2>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIPickerViewSubclass2?
        
    required init(parentObject: UIPickerViewSubclass2) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}
    
final class UIPickerViewSubclass2: UIPickerView, TestDelegateControl {
    func doThatTest(_ value: Int) {
        if dataSource != nil {
            (dataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }
    
    var delegateProxy: DelegateProxy<UIPickerViewSubclass2, UIPickerViewDataSource> {
        return self.rx.dataSource
    }
    
    func setMineForwardDelegate(_ testDelegate: UIPickerViewDataSource) -> Disposable {
        return RxPickerViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendWebViewDelegateProxy
    : RxWebViewDelegateProxy<UIWebViewSubclass>
    , TestDelegateProtocol {
    required init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class UIWebViewSubclass: UIWebView, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIWebViewSubclass, UIWebViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIWebViewDelegate) -> Disposable {
        return RxWebViewDelegateProxy.installForwardDelegate(testDelegate,
                                                             retainDelegate: false,
                                                             onProxyForObject: self)
    }
    
}

#endif



final class ExtendTextStorageDelegateProxy
    : RxTextStorageDelegateProxy<NSTextStorageSubclass>
    , TestDelegateProtocol {

    required init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class NSTextStorageSubclass
    : NSTextStorage
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<NSTextStorageSubclass, NSTextStorageDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: NSTextStorageDelegate) -> Disposable {
        return RxTextStorageDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendNavigationControllerDelegateProxy
    : RxNavigationControllerDelegateProxy<UINavigationControllerSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UINavigationControllerSubclass?

    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class ExtendTabBarControllerDelegateProxy
    : RxTabBarControllerDelegateProxy<UITabBarControllerSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarControllerSubclass?
    
    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class ExtendTabBarDelegateProxy
    : RxTabBarDelegateProxy<UITabBarSubclass>
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarSubclass?
    
    required init(parentObject: ParentObject) {
        self.control = parentObject
        super.init(parentObject: parentObject)
    }
}

final class UINavigationControllerSubclass: UINavigationController, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UINavigationControllerSubclass, UINavigationControllerDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UINavigationControllerDelegate) -> Disposable {
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
    
    var delegateProxy: DelegateProxy<UITabBarControllerSubclass, UITabBarControllerDelegate> {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: UITabBarControllerDelegate) -> Disposable {
        return RxTabBarControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class UITabBarSubclass: UITabBar, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UITabBarSubclass, UITabBarDelegate> {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: UITabBarDelegate) -> Disposable {
        return RxTabBarDelegateProxy.installForwardDelegate(testDelegate,
                                                            retainDelegate: false,
                                                            onProxyForObject: self)
    }
}
