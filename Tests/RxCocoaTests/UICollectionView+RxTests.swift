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

    func testCollectionView_itemHighlighted() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.itemHighlighted
            .subscribe(onNext: { indexPath in
                resultIndexPath = indexPath
            })

        let testRow = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didHighlightItemAt: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testCollectionView_itemUnhighlighted() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.itemUnhighlighted
            .subscribe(onNext: { indexPath in
                resultIndexPath = indexPath
            })

        let testRow = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didUnhighlightItemAt: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testCollectionView_willDisplayCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultCell: UICollectionViewCell? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.willDisplayCell
            .subscribe(onNext: { (cell, indexPath) in
                resultCell = cell
                resultIndexPath = indexPath
            })

        let testCell = UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        let testIndexPath = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, willDisplay: testCell, forItemAt: testIndexPath)

        XCTAssertEqual(resultCell, testCell)
        XCTAssertEqual(resultIndexPath, testIndexPath)
        subscription.dispose()
    }

    func testCollectionView_willDisplaySupplementaryView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultSupplementaryView: UICollectionReusableView? = nil
        var resultElementKind: String? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.willDisplaySupplementaryView
            .subscribe(onNext: { (reuseableView, elementKind, indexPath) in
                resultSupplementaryView = reuseableView
                resultElementKind = elementKind
                resultIndexPath = indexPath
            })

        let testSupplementaryView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        let testElementKind = UICollectionElementKindSectionHeader
        let testIndexPath = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, willDisplaySupplementaryView: testSupplementaryView, forElementKind: testElementKind, at: testIndexPath)

        XCTAssertEqual(resultSupplementaryView, testSupplementaryView)
        XCTAssertEqual(resultElementKind, testElementKind)
        XCTAssertEqual(resultIndexPath, testIndexPath)
        subscription.dispose()
    }

    func testCollectionView_didEndDisplayingCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultCell: UICollectionViewCell? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.didEndDisplayingCell
            .subscribe(onNext: { (cell, indexPath) in
                resultCell = cell
                resultIndexPath = indexPath
            })

        let testCell = UICollectionViewCell(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        let testRow = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didEndDisplaying: testCell, forItemAt: testRow)

        XCTAssertEqual(resultCell, testCell)
        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testCollectionView_didEndDisplayingSupplementaryView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultSupplementaryView: UICollectionReusableView? = nil
        var resultElementKind: String? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.didEndDisplayingSupplementaryView
            .subscribe(onNext: { (reuseableView, elementKind, indexPath) in
                resultSupplementaryView = reuseableView
                resultElementKind = elementKind
                resultIndexPath = indexPath
            })

        let testSupplementaryView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        let testElementKind = UICollectionElementKindSectionHeader
        let testIndexPath = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didEndDisplayingSupplementaryView: testSupplementaryView, forElementOfKind: testElementKind, at: testIndexPath)

        XCTAssertEqual(resultSupplementaryView, testSupplementaryView)
        XCTAssertEqual(resultElementKind, testElementKind)
        XCTAssertEqual(resultIndexPath, testIndexPath)
        subscription.dispose()
    }

    func testCollectionView_DelegateEventCompletesOnDealloc1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            let s = items.bind(to: collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
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
            let s = items.bind(to: collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

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
            let s = items.bind(to: collectionView.rx.items(cellIdentifier: "a", cellType: UICollectionViewCell.self)) { (index: Int, item: Int, cell) in

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
            let s = items.bind(to: collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
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
            let dataSourceSubscription = items.bind(to: collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

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

            let s = items.bind(to: collectionView.rx.items) { (cv, index: Int, item: Int) -> UICollectionViewCell in
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
            let dataSourceSubscription = items.bind(to: collectionView.rx.items(cellIdentifier: "a")) { (index: Int, item: Int, cell) in

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
            let dataSourceSubscription = items.bind(to: collectionView.rx.items(dataSource: dataSource))

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
            dataSourceSubscription = items.bind(to: collectionView.rx.items(dataSource: dataSource))

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
            _ = items.bind(to: collectionView.rx.items(dataSource: dataSource))
            
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

    func testCollectionViewDataSourceIsResetOnDispose() {
        var disposeEvents: [String] = []

        let items: Observable<[Int]> = Observable.just([1, 2, 3]).concat(Observable.never())
            .do(onDispose: {
                disposeEvents.append("disposed")
            })

        let layout = UICollectionViewFlowLayout()
        let createView: () -> (UICollectionView, Disposable) = {
            let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)
            collectionView.register(NSClassFromString("UICollectionViewCell"), forCellWithReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            let dataSourceSubscription = items.bind(to: collectionView.rx.items(dataSource: dataSource))

            return (collectionView, dataSourceSubscription)

        }
        let (collectionView, dataSourceSubscription) = createView()

        XCTAssertTrue(collectionView.dataSource === RxCollectionViewDataSourceProxy.proxyForObject(collectionView))

        _ = collectionView.rx.sentMessage(#selector(UICollectionView.layoutIfNeeded)).subscribe(onNext: { _ in
            disposeEvents.append("layoutIfNeeded")
        })
        _ = collectionView.rx.sentMessage(NSSelectorFromString("setDataSource:")).subscribe(onNext: { arguments in
            let isNull = NSNull().isEqual(arguments[0])
            disposeEvents.append("setDataSource:\(isNull ? "nil" : "nn")")
        })
        
        XCTAssertEqual(disposeEvents, [])
        dataSourceSubscription.dispose()
        XCTAssertEqual(disposeEvents, ["disposed", "layoutIfNeeded", "setDataSource:nil", "setDataSource:nn"])

        XCTAssertTrue(collectionView.dataSource === collectionView.rx.dataSource)
    }
}
