//
//  UICollectionView+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import XCTest

// UICollectionView
class UICollectionViewTests : RxTest {
    func testCollectionView_DelegateEventCompletesOnDealloc() {
        let layout = UICollectionViewFlowLayout()
        let createView: () -> UICollectionView = { UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout) }

        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_itemSelected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_itemDeselected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx_modelDeselected(Int.self) }
    }

    func testCollectionView_itemSelected() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)

        var resultIndexPath: NSIndexPath? = nil

        let subscription = collectionView.rx_itemSelected
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        collectionView.delegate!.collectionView!(collectionView, didSelectItemAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testCollectionView_itemDeselected() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)

        var resultIndexPath: NSIndexPath? = nil

        let subscription = collectionView.rx_itemDeselected
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
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

    func testCollectionView_ModelSelected_itemsWithCellFactory() {
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

    func testCollectionView_ModelSelected_itemsWithCellIdentifier() {
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

    func testCollectionView_ModelDeselected_itemsWithCellFactory() {
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

        let s = collectionView.rx_modelDeselected(Int.self)
            .subscribeNext { (item: Int) in
                selectedItem = item
        }

        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testCollectionView_ModelDeselected_itemsWithCellIdentifier() {
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

        let s = collectionView.rx_modelDeselected(Int.self)
            .subscribeNext { item in
                selectedItem = item
            }

        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        
        XCTAssertEqual(selectedItem, 2)
        
        s.dispose()
        dataSourceSubscription.dispose()
    }

    func testCollectionView_modelAtIndexPath_normal() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRectMake(0, 0, 1, 1), collectionViewLayout: layout)
            collectionView.registerClass(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            let dataSourceSubscription = items.bindTo(collectionView.rx_itemsWithDataSource(dataSource))

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        let model: Int = try! collectionView.rx_modelAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))

        XCTAssertEqual(model, 2)

        dataSourceSubscription.dispose()
    }
}