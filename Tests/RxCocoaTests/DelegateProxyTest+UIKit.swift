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
        performDelegateTest(UITableViewSubclass1(frame: CGRect.zero)) { ExtendTableViewDelegateProxy(tableViewSubclass: $0) }
    }

    func test_UITableViewDataSourceExtension() {
        performDelegateTest(UITableViewSubclass2(frame: CGRect.zero)) { ExtendTableViewDataSourceProxy(tableViewSubclass: $0) }
    }

    @available(iOS 10.0, tvOS 10.0, *)
    func test_UITableViewDataSourcePrefetchingExtension() {
        performDelegateTest(UITableViewSubclass3(frame: CGRect.zero)) { ExtendTableViewDataSourcePrefetchingProxy(parentObject: $0) }
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

    @available(iOS 10.0, tvOS 10.0, *)
    func test_UICollectionViewDataSourcePrefetchingExtension() {
        let layout = UICollectionViewFlowLayout()
        performDelegateTest(UICollectionViewSubclass3(frame: CGRect.zero, collectionViewLayout: layout)) { ExtendCollectionViewDataSourcePrefetchingProxy(parentObject: $0) }
    }
}

extension DelegateProxyTest {
    func test_UINavigationControllerDelegateExtension() {
        performDelegateTest(UINavigationControllerSubclass()) { ExtendNavigationControllerDelegateProxy(navigationControllerSubclass: $0) }
    }
}

extension DelegateProxyTest {
    func test_UIScrollViewDelegateExtension() {
        performDelegateTest(UIScrollViewSubclass(frame: CGRect.zero)) { ExtendScrollViewDelegateProxy(scrollViewSubclass: $0) }
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchBarDelegateExtension() {
        performDelegateTest(UISearchBarSubclass(frame: CGRect.zero)) { ExtendSearchBarDelegateProxy(searchBarSubclass: $0) }
    }
}
#endif

extension DelegateProxyTest {
    func test_UITextViewDelegateExtension() {
        performDelegateTest(UITextViewSubclass(frame: CGRect.zero)) { ExtendTextViewDelegateProxy(textViewSubclass: $0) }
    }
}

#if os(iOS)
extension DelegateProxyTest {
    func test_UISearchController() {
        performDelegateTest(UISearchControllerSubclass()) { ExtendSearchControllerDelegateProxy(searchControllerSubclass: $0) }
    }
}
    
extension DelegateProxyTest {
    func test_UIPickerViewExtension() {
        performDelegateTest(UIPickerViewSubclass(frame: CGRect.zero)) { ExtendPickerViewDelegateProxy(pickerViewSubclass: $0) }
    }
    
    func test_UIPickerViewDataSourceExtension() {
        performDelegateTest(UIPickerViewSubclass2(frame: CGRect.zero)) { ExtendPickerViewDataSourceProxy(pickerViewSubclass: $0) }
    }
}
#endif

#if os(iOS)
extension DelegateProxyTest {
    func test_UIWebViewDelegateExtension() {
        performDelegateTest(UIWebViewSubclass(frame: CGRect.zero)) { ExtendWebViewDelegateProxy(webViewSubclass: $0) }
    }
}
#endif

extension DelegateProxyTest {
    func test_UITabBarControllerDelegateExtension() {
        performDelegateTest(UITabBarControllerSubclass()) { ExtendTabBarControllerDelegateProxy(tabBarControllerSubclass: $0) }
    }
}

extension DelegateProxyTest {
    func test_UITabBarDelegateExtension() {
        performDelegateTest(UITabBarSubclass()) { ExtendTabBarDelegateProxy(tabBarSubclass: $0) }
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

    init(tableViewSubclass: UITableViewSubclass1) {
        self.control = tableViewSubclass
        super.init(tableView: tableViewSubclass)
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

    init(tableViewSubclass: UITableViewSubclass2) {
        self.control = tableViewSubclass
        super.init(tableView: tableViewSubclass)
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

@available(iOS 10.0, tvOS 10.0, *)
final class ExtendTableViewDataSourcePrefetchingProxy
    : RxTableViewDataSourcePrefetchingProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITableViewSubclass3?

    init(parentObject: UITableViewSubclass3) {
        self.control = parentObject
        super.init(tableView: parentObject)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class UITableViewSubclass3
    : UITableView
    , TestDelegateControl {

    func doThatTest(_ value: Int) {
        if prefetchDataSource != nil {
            (prefetchDataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UITableView, UITableViewDataSourcePrefetching> {
        return self.rx.prefetchDataSource
    }

    func setMineForwardDelegate(_ testDelegate: UITableViewDataSourcePrefetching) -> Disposable {
        return RxTableViewDataSourcePrefetchingProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDelegateProxy
    : RxCollectionViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass1?

    init(parentObject: UICollectionViewSubclass1) {
        self.control = parentObject
        super.init(collectionView: parentObject)
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
        super.init(collectionView: parentObject)
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

@available(iOS 10.0, tvOS 10.0, *)
final class ExtendCollectionViewDataSourcePrefetchingProxy
    : RxCollectionViewDataSourcePrefetchingProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UICollectionViewSubclass3?

    init(parentObject: UICollectionViewSubclass3) {
        self.control = parentObject
        super.init(collectionView: parentObject)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class UICollectionViewSubclass3
    : UICollectionView
    , TestDelegateControl {

    func doThatTest(_ value: Int) {
        if prefetchDataSource != nil {
            (prefetchDataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UICollectionView, UICollectionViewDataSourcePrefetching> {
        return self.rx.prefetchDataSource
    }

    func setMineForwardDelegate(_ testDelegate: UICollectionViewDataSourcePrefetching) -> Disposable {
        return RxCollectionViewDataSourcePrefetchingProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendScrollViewDelegateProxy
    : RxScrollViewDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UIScrollViewSubclass?

    init(scrollViewSubclass: UIScrollViewSubclass) {
        self.control = scrollViewSubclass
        super.init(scrollView: scrollViewSubclass)
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
    
    init(searchBarSubclass: UISearchBarSubclass) {
        self.control = searchBarSubclass
        super.init(searchBar: searchBarSubclass)
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

    init(textViewSubclass: UITextViewSubclass) {
        self.control = textViewSubclass
        super.init(textView: textViewSubclass)
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
    init(searchControllerSubclass: UISearchControllerSubclass) {
        super.init(searchController: searchControllerSubclass)
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
    init(pickerViewSubclass: UIPickerViewSubclass) {
        super.init(pickerView: pickerViewSubclass)
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
        
    init(pickerViewSubclass: UIPickerViewSubclass2) {
        self.control = pickerViewSubclass
        super.init(pickerView: pickerViewSubclass)
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
    init(webViewSubclass: UIWebViewSubclass) {
        super.init(webView: webViewSubclass)
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

    init(textStorageSubclass: NSTextStorageSubclass) {
        super.init(textStorage: textStorageSubclass)
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

    init(navigationControllerSubclass: UINavigationControllerSubclass) {
        self.control = navigationControllerSubclass
        super.init(navigationController: navigationControllerSubclass)
    }
}

final class ExtendTabBarControllerDelegateProxy
    : RxTabBarControllerDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var tabBarControllerSubclass: UITabBarControllerSubclass?
    
    init(tabBarControllerSubclass: UITabBarControllerSubclass) {
        self.tabBarControllerSubclass = tabBarControllerSubclass
        super.init(tabBar: tabBarControllerSubclass)
    }
}

final class ExtendTabBarDelegateProxy
    : RxTabBarDelegateProxy
    , TestDelegateProtocol {
    weak fileprivate(set) var control: UITabBarSubclass?
    
    init(tabBarSubclass: UITabBarSubclass) {
        self.control = tabBarSubclass
        super.init(tabBar: tabBarSubclass)
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
