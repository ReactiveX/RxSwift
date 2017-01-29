//
//  UICollectionView+RxTests.swift
//  Tests
//
//  Created by Krunoslav Zaher on 4/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa
import XCTest

// UICollectionView
final class UICollectionViewTests : RxTest {
    func testCollectionView_DelegateEventCompletesOnDealloc() {
        let layout = UICollectionViewFlowLayout()
        let createView: () -> UICollectionView = { UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout) }

        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.itemSelected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.itemDeselected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelDeselected(Int.self) }
    }

    func testCollectionView_itemSelected() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.itemSelected
            .subscribe(onNext: { indexPath in
                resultIndexPath = indexPath
            })

        let testRow = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didSelectItemAt: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testCollectionView_itemDeselected() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.itemDeselected
            .subscribe(onNext: { indexPath in
                resultIndexPath = indexPath
            })

        let testRow = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAt: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }


    func testCollectionView_DelegateEventCompletesOnDealloc1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            let s = items.bindTo(collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
                return UICollectionViewCell(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelSelected(Int.self) }
    }

    func testCollectionView_DelegateEventCompletesOnDealloc2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let s = items.bindTo(collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelSelected(Int.self) }
    }

    func testCollectionView_DelegateEventCompletesOnDealloc2_cellType() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let s = items.bindTo(collectionView.rx.items(cellIdentifier: "a", cellType: UICollectionViewCell.self)) { (index: Int, item: Int, cell) in

            }

            return (collectionView, s)
        }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelSelected(Int.self) }
    }

    func testCollectionView_ModelSelected_itemsWithCellFactory() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 20.0, height: 20.0)

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: layout)
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "a")
            let s = items.bindTo(collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
                return collectionView.dequeueReusableCell(withReuseIdentifier: "a", for: IndexPath(item: index, section: 0))
            }

            return (collectionView, s)
        }

        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx.modelSelected(Int.self)
            .subscribe(onNext: { (item: Int) in
                selectedItem = item
            })

        collectionView.delegate!.collectionView!(collectionView, didSelectItemAt: IndexPath(row: 1, section: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testCollectionView_ModelSelected_itemsWithCellIdentifier() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

            }

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx.modelSelected(Int.self)
            .subscribe(onNext: { item in
                selectedItem = item
            })

        collectionView.delegate!.collectionView!(collectionView, didSelectItemAt: IndexPath(row: 1, section: 0))

        XCTAssertEqual(selectedItem, 2)
        
        s.dispose()
        dataSourceSubscription.dispose()
    }

    func testCollectionView_ModelDeselected_itemsWithCellFactory() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 20.0, height: 20.0)

        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")

            let s = items.bindTo(collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
                return collectionView.dequeueReusableCell(withReuseIdentifier: "a", for: IndexPath(item: index, section: 0))
            }

            return (collectionView, s)
        }

        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx.modelDeselected(Int.self)
            .subscribe(onNext: { (item: Int) in
                selectedItem = item
            })

        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAt: IndexPath(row: 1, section: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testCollectionView_ModelDeselected_itemsWithCellIdentifier() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

            }

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = collectionView.rx.modelDeselected(Int.self)
            .subscribe(onNext: { item in
                selectedItem = item
            })

        collectionView.delegate!.collectionView!(collectionView, didDeselectItemAt: IndexPath(row: 1, section: 0))
        
        XCTAssertEqual(selectedItem, 2)
        
        s.dispose()
        dataSourceSubscription.dispose()
    }

    func testCollectionView_modelAtIndexPath_normal() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            let dataSourceSubscription = items.bindTo(collectionView.rx.items(dataSource: dataSource))

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        let model: Int = try! collectionView.rx.model(at: IndexPath(item: 1, section: 0))

        XCTAssertEqual(model, 2)

        dataSourceSubscription.dispose()
    }
}

extension UICollectionViewTests {
    func testDataSourceIsBeingRetainedUntilDispose() {
        var dataSourceDeallocated = false

        var collectionViewOuter: UICollectionView? = nil
        var dataSourceSubscription: Disposable!
        collectionViewOuter?.becomeFirstResponder()
        autoreleasepool {
            let items: Observable<[Int]> = Observable.just([1, 2, 3])

            let layout = UICollectionViewFlowLayout()
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "a")
            collectionViewOuter = collectionView
            let dataSource = SectionedViewDataSourceMock()
            dataSourceSubscription = items.bindTo(collectionView.rx.items(dataSource: dataSource))

            _ = dataSource.rx.deallocated.subscribe(onNext: { _ in
                dataSourceDeallocated = true
            })
        }

        XCTAssert(dataSourceDeallocated == false)
        autoreleasepool { dataSourceSubscription.dispose() }
        XCTAssert(dataSourceDeallocated == true)
    }

    func testDataSourceIsBeingRetainedUntilCollectionViewDealloc() {

        var dataSourceDeallocated = false

        autoreleasepool {
            let items: Observable<[Int]> = Observable.just([1, 2, 3])

            let layout = UICollectionViewFlowLayout()
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            _ = items.bindTo(collectionView.rx.items(dataSource: dataSource))
            
            _ = dataSource.rx.deallocated.subscribe(onNext: { _ in
                dataSourceDeallocated = true
            })

            XCTAssert(dataSourceDeallocated == false)
        }
        XCTAssert(dataSourceDeallocated == true)
    }

    func testSetDataSourceUsesWeakReference() {

        var dataSourceDeallocated = false

        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
        autoreleasepool {
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            _ = collectionView.rx.setDataSource(dataSource)

            _ = dataSource.rx.deallocated.subscribe(onNext: { _ in
                dataSourceDeallocated = true
            })

            XCTAssert(dataSourceDeallocated == false)
        }
        XCTAssert(dataSourceDeallocated == true)
    }

    func testCollectionViewDataSourceIsNilOnDispose() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            let dataSourceSubscription = items.bindTo(collectionView.rx.items(dataSource: dataSource))

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        XCTAssertTrue(collectionView.dataSource === RxCollectionViewDataSourceProxy.proxyForObject(collectionView))
        
        dataSourceSubscription.dispose()

        XCTAssertTrue(collectionView.dataSource === nil)
    }
}
