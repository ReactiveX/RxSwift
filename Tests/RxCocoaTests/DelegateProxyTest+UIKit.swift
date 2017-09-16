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
        performDelegateTest(UITableViewSubclass1(frame: CGRect.zero)) { ExtendTableViewDelegateProxy(parentObject: $0) }
    }

    func test_UITableViewDataSourceExtension() {
        performDelegateTest(UITableViewSubclass2(frame: CGRect.zero)) { ExtendTableViewDataSourceProxy(parentObject: $0) }
    }
}

extension DelegateProxyTest {

    func test_UICollectionViewDelegateExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass1(frame: CGRect.zero, collectionViewLayout: layout)) { ExtendCollectionViewDelegateProxy(parentObject: $0) }
    }

    func test_UICollectionViewDataSourceExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass2(frame: CGRect.zero, collectionViewLayout: layout)) { ExtendCollectionViewDataSourceProxy(parentObject: $0) }
    }
}

extension DelegateProxyTest {
    func test_UINavigationControllerDelegateExtension() {
        performDelegateTest(UINavigationControllerSubclass()) { ExtendNavigationControllerDelegateProxy(parentObject: $0) }
    }
}

extension DelegateProxyTest {
    func test_UIScrollViewDelegateExtension() {
        performDelegateTest(UIScrollViewSubclass(frame: CGRect.zero)) { ExtendScrollViewDelegateProxy(parentObject: $0) }
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchBarDelegateExtension() {
        performDelegateTest(UISearchBarSubclass(frame: CGRect.zero)) { ExtendSearchBarDelegateProxy(parentObject: $0) }
    }
}
#endif

extension DelegateProxyTest {
    func test_UITextViewDelegateExtension() {
        performDelegateTest(UITextViewSubclass(frame: CGRect.zero)) { ExtendTextViewDelegateProxy(parentObject: $0) }
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchController() {
        performDelegateTest(UISearchControllerSubclass()) { ExtendSearchControllerDelegateProxy(parentObject: $0) }
    }
}
    
extension DelegateProxyTest {
    func test_UIPickerViewExtension() {
        performDelegateTest(UIPickerViewSubclass(frame: CGRect.zero)) { ExtendPickerViewDelegateProxy(parentObject: $0) }
    }
    
    func test_UIPickerViewDataSourceExtension() {
        performDelegateTest(UIPickerViewSubclass2(frame: CGRect.zero)) { ExtendPickerViewDataSourceProxy(parentObject: $0) }
    }
}
#endif

#if os(iOS)
extension DelegateProxyTest {
    func test_UIWebViewDelegateExtension() {
        performDelegateTest(UIWebViewSubclass(frame: CGRect.zero)) { ExtendWebViewDelegateProxy(parentObject: $0) }
    }
}
#endif

extension DelegateProxyTest {
    func test_UITabBarControllerDelegateExtension() {
        performDelegateTest(UITabBarControllerSubclass()) { ExtendTabBarControllerDelegateProxy(parentObject: $0) }
    }
}

extension DelegateProxyTest {
    func test_UITabBarDelegateExtension() {
        performDelegateTest(UITabBarSubclass()) { ExtendTabBarDelegateProxy(parentObject: $0) }
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

    override init(parentObject: UITableView) {
        self.control = parentObject as? UITableViewSubclass1
        super.init(parentObject: parentObject)
    }
}

final class UITableViewSubclass1
    : UITableView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendTableViewDataSourceProxy
    : RxTableViewDataSourceProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass2?

 init(parentObject: UITableViewSubclass2) {
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

    var delegateProxy: DelegateProxy<UITableView, UITableViewDataSource> {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UITableViewDataSource) -> Disposable {
        return RxTableViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDelegateProxy
    : RxCollectionViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass1?

    init(parentObject: UICollectionViewSubclass1) {
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

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDataSourceProxy
    : RxCollectionViewDataSourceProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass2?

    init(parentObject: UICollectionViewSubclass2) {
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

    var delegateProxy: DelegateProxy<UICollectionView, UICollectionViewDataSource> {
        return self.rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UICollectionViewDataSource) -> Disposable {
        return RxCollectionViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendScrollViewDelegateProxy
    : RxScrollViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIScrollViewSubclass?

    override init(parentObject: ParentObject) {
        self.control = parentObject as? UIScrollViewSubclass
        super.init(parentObject: parentObject)
    }
}

final class UIScrollViewSubclass
    : UIScrollView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

#if os(iOS)
final class ExtendSearchBarDelegateProxy
    : RxSearchBarDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UISearchBarSubclass?
    
    override init(parentObject: ParentObject) {
        self.control = parentObject as? UISearchBarSubclass
        super.init(parentObject: parentObject)
    }
}

final class UISearchBarSubclass
    : UISearchBar
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UISearchBar, UISearchBarDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchBarDelegate) -> Disposable {
        return RxSearchBarDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#endif

final class ExtendTextViewDelegateProxy
    : RxTextViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITextViewSubclass?

 init(parentObject: UITextViewSubclass) {
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

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        return RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#if os(iOS)
final class ExtendSearchControllerDelegateProxy
    : RxSearchControllerDelegateProxy
    , TestDelegateProtocol {
    override init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class UISearchControllerSubclass
    : UISearchController
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UISearchController, UISearchControllerDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchControllerDelegate) -> Disposable {
        return RxSearchControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}


final class ExtendPickerViewDelegateProxy
    : RxPickerViewDelegateProxy
    , TestDelegateProtocol {
    override init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}
    
final class UIPickerViewSubclass
    : UIPickerView
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }
    
    var delegateProxy: DelegateProxy<UIPickerView, UIPickerViewDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIPickerViewDelegate) -> Disposable {
        return RxPickerViewDelegateProxy.installForwardDelegate(testDelegate,
                                                                retainDelegate: false,
                                                                onProxyForObject: self)
    }
}
    
final class ExtendPickerViewDataSourceProxy
    : RxPickerViewDataSourceProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIPickerViewSubclass2?
        
    init(parentObject: UIPickerViewSubclass2) {
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
    
    var delegateProxy: DelegateProxy<UIPickerView, UIPickerViewDataSource> {
        return self.rx.dataSource
    }
    
    func setMineForwardDelegate(_ testDelegate: UIPickerViewDataSource) -> Disposable {
        return RxPickerViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendWebViewDelegateProxy
    : RxWebViewDelegateProxy
    , TestDelegateProtocol {
    override init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class UIWebViewSubclass: UIWebView, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIWebView, UIWebViewDelegate> {
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
    : RxTextStorageDelegateProxy
    , TestDelegateProtocol {

    override init(parentObject: ParentObject) {
        super.init(parentObject: parentObject)
    }
}

final class NSTextStorageSubclass
    : NSTextStorage
    , TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<NSTextStorage, NSTextStorageDelegate> {
        return self.rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: NSTextStorageDelegate) -> Disposable {
        return RxTextStorageDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendNavigationControllerDelegateProxy
    : RxNavigationControllerDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UINavigationControllerSubclass?

    override init(parentObject: ParentObject) {
        self.control = parentObject as? UINavigationControllerSubclass
        super.init(parentObject: parentObject)
    }
}

final class ExtendTabBarControllerDelegateProxy
    : RxTabBarControllerDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarControllerSubclass?
    
    override init(parentObject: ParentObject) {
        self.control = parentObject as? UITabBarControllerSubclass
        super.init(parentObject: parentObject)
    }
}

final class ExtendTabBarDelegateProxy
    : RxTabBarDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarSubclass?
    
    override init(parentObject: ParentObject) {
        self.control = parentObject as? UITabBarSubclass
        super.init(parentObject: parentObject)
    }
}

final class UINavigationControllerSubclass: UINavigationController, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UINavigationController, UINavigationControllerDelegate> {
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
    
    var delegateProxy: DelegateProxy<UITabBarController, UITabBarControllerDelegate> {
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
    
    var delegateProxy: DelegateProxy<UITabBar, UITabBarDelegate> {
        return self.rx.delegate
    }
    
    func setMineForwardDelegate(_ testDelegate: UITabBarDelegate) -> Disposable {
        return RxTabBarDelegateProxy.installForwardDelegate(testDelegate,
                                                            retainDelegate: false,
                                                            onProxyForObject: self)
    }
}
