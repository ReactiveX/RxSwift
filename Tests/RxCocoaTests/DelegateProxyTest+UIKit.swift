//
//  DelegateProxyTest+UIKit.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

@testable import RxCocoa
@testable import RxSwift
import UIKit
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

final class ExtendTableViewDelegateProxy:
    RxTableViewDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UITableViewSubclass1?

    init(tableViewSubclass: UITableViewSubclass1) {
        control = tableViewSubclass
        super.init(tableView: tableViewSubclass)
    }
}

final class UITableViewSubclass1:
    UITableView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendTableViewDataSourceProxy:
    RxTableViewDataSourceProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UITableViewSubclass2?

    init(tableViewSubclass: UITableViewSubclass2) {
        control = tableViewSubclass
        super.init(tableView: tableViewSubclass)
    }
}

final class UITableViewSubclass2:
    UITableView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        if dataSource != nil {
            (dataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UITableView, UITableViewDataSource> {
        rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UITableViewDataSource) -> Disposable {
        RxTableViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class ExtendTableViewDataSourcePrefetchingProxy:
    RxTableViewDataSourcePrefetchingProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UITableViewSubclass3?

    init(parentObject: UITableViewSubclass3) {
        control = parentObject
        super.init(tableView: parentObject)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class UITableViewSubclass3:
    UITableView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        if prefetchDataSource != nil {
            (prefetchDataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UITableView, UITableViewDataSourcePrefetching> {
        rx.prefetchDataSource
    }

    func setMineForwardDelegate(_ testDelegate: UITableViewDataSourcePrefetching) -> Disposable {
        RxTableViewDataSourcePrefetchingProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDelegateProxy:
    RxCollectionViewDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UICollectionViewSubclass1?

    init(parentObject: UICollectionViewSubclass1) {
        control = parentObject
        super.init(collectionView: parentObject)
    }
}

final class UICollectionViewSubclass1:
    UICollectionView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendCollectionViewDataSourceProxy:
    RxCollectionViewDataSourceProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UICollectionViewSubclass2?

    init(parentObject: UICollectionViewSubclass2) {
        control = parentObject
        super.init(collectionView: parentObject)
    }
}

final class UICollectionViewSubclass2:
    UICollectionView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        if dataSource != nil {
            (dataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UICollectionView, UICollectionViewDataSource> {
        rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UICollectionViewDataSource) -> Disposable {
        RxCollectionViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class ExtendCollectionViewDataSourcePrefetchingProxy:
    RxCollectionViewDataSourcePrefetchingProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UICollectionViewSubclass3?

    init(parentObject: UICollectionViewSubclass3) {
        control = parentObject
        super.init(collectionView: parentObject)
    }
}

@available(iOS 10.0, tvOS 10.0, *)
final class UICollectionViewSubclass3:
    UICollectionView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        if prefetchDataSource != nil {
            (prefetchDataSource as! TestDelegateProtocol).testEventHappened?(value)
        }
    }

    var delegateProxy: DelegateProxy<UICollectionView, UICollectionViewDataSourcePrefetching> {
        rx.prefetchDataSource
    }

    func setMineForwardDelegate(_ testDelegate: UICollectionViewDataSourcePrefetching) -> Disposable {
        RxCollectionViewDataSourcePrefetchingProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendScrollViewDelegateProxy:
    RxScrollViewDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UIScrollViewSubclass?

    init(scrollViewSubclass: UIScrollViewSubclass) {
        control = scrollViewSubclass
        super.init(scrollView: scrollViewSubclass)
    }
}

final class UIScrollViewSubclass:
    UIScrollView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

#if os(iOS)
final class ExtendSearchBarDelegateProxy:
    RxSearchBarDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UISearchBarSubclass?

    init(searchBarSubclass: UISearchBarSubclass) {
        control = searchBarSubclass
        super.init(searchBar: searchBarSubclass)
    }
}

final class UISearchBarSubclass:
    UISearchBar,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UISearchBar, UISearchBarDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchBarDelegate) -> Disposable {
        RxSearchBarDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#endif

final class ExtendTextViewDelegateProxy:
    RxTextViewDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UITextViewSubclass?

    init(textViewSubclass: UITextViewSubclass) {
        control = textViewSubclass
        super.init(textView: textViewSubclass)
    }
}

final class UITextViewSubclass:
    UITextView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIScrollView, UIScrollViewDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIScrollViewDelegate) -> Disposable {
        RxScrollViewDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

#if os(iOS)
final class ExtendSearchControllerDelegateProxy:
    RxSearchControllerDelegateProxy,
    TestDelegateProtocol
{
    init(searchControllerSubclass: UISearchControllerSubclass) {
        super.init(searchController: searchControllerSubclass)
    }
}

final class UISearchControllerSubclass:
    UISearchController,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UISearchController, UISearchControllerDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UISearchControllerDelegate) -> Disposable {
        RxSearchControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendPickerViewDelegateProxy:
    RxPickerViewDelegateProxy,
    TestDelegateProtocol
{
    init(pickerViewSubclass: UIPickerViewSubclass) {
        super.init(pickerView: pickerViewSubclass)
    }
}

final class UIPickerViewSubclass:
    UIPickerView,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UIPickerView, UIPickerViewDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UIPickerViewDelegate) -> Disposable {
        RxPickerViewDelegateProxy.installForwardDelegate(
            testDelegate,
            retainDelegate: false,
            onProxyForObject: self,
        )
    }
}

final class ExtendPickerViewDataSourceProxy:
    RxPickerViewDataSourceProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UIPickerViewSubclass2?

    init(pickerViewSubclass: UIPickerViewSubclass2) {
        control = pickerViewSubclass
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
        rx.dataSource
    }

    func setMineForwardDelegate(_ testDelegate: UIPickerViewDataSource) -> Disposable {
        RxPickerViewDataSourceProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}
#endif

final class ExtendTextStorageDelegateProxy:
    RxTextStorageDelegateProxy,
    TestDelegateProtocol
{
    init(textStorageSubclass: NSTextStorageSubclass) {
        super.init(textStorage: textStorageSubclass)
    }
}

final class NSTextStorageSubclass:
    NSTextStorage,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<NSTextStorage, NSTextStorageDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: NSTextStorageDelegate) -> Disposable {
        RxTextStorageDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class ExtendNavigationControllerDelegateProxy:
    RxNavigationControllerDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UINavigationControllerSubclass?

    init(navigationControllerSubclass: UINavigationControllerSubclass) {
        control = navigationControllerSubclass
        super.init(navigationController: navigationControllerSubclass)
    }
}

final class ExtendTabBarControllerDelegateProxy:
    RxTabBarControllerDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var tabBarControllerSubclass: UITabBarControllerSubclass?

    init(tabBarControllerSubclass: UITabBarControllerSubclass) {
        self.tabBarControllerSubclass = tabBarControllerSubclass
        super.init(tabBar: tabBarControllerSubclass)
    }
}

final class ExtendTabBarDelegateProxy:
    RxTabBarDelegateProxy,
    TestDelegateProtocol
{
    private(set) weak var control: UITabBarSubclass?

    init(tabBarSubclass: UITabBarSubclass) {
        control = tabBarSubclass
        super.init(tabBar: tabBarSubclass)
    }
}

final class UINavigationControllerSubclass: UINavigationController, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UINavigationController, UINavigationControllerDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UINavigationControllerDelegate) -> Disposable {
        RxNavigationControllerDelegateProxy.installForwardDelegate(
            testDelegate,
            retainDelegate: false,
            onProxyForObject: self,
        )
    }
}

final class UITabBarControllerSubclass:
    UITabBarController,
    TestDelegateControl
{
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UITabBarController, UITabBarControllerDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UITabBarControllerDelegate) -> Disposable {
        RxTabBarControllerDelegateProxy.installForwardDelegate(testDelegate, retainDelegate: false, onProxyForObject: self)
    }
}

final class UITabBarSubclass: UITabBar, TestDelegateControl {
    func doThatTest(_ value: Int) {
        (delegate as! TestDelegateProtocol).testEventHappened?(value)
    }

    var delegateProxy: DelegateProxy<UITabBar, UITabBarDelegate> {
        rx.delegate
    }

    func setMineForwardDelegate(_ testDelegate: UITabBarDelegate) -> Disposable {
        RxTabBarDelegateProxy.installForwardDelegate(
            testDelegate,
            retainDelegate: false,
            onProxyForObject: self,
        )
    }
}
