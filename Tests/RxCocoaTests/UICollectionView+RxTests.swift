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
    func test_DelegateEventCompletesOnDealloc() {
        let layout = UICollectionViewFlowLayout()
        let createView: () -> UICollectionView = { UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout) }

        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.itemSelected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.itemDeselected }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.modelDeselected(Int.self) }

        #if os(tvOS)
            ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.didUpdateFocusInContextWithAnimationCoordinator }
        #endif
    }

    func test_itemSelected() {
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

    func test_itemDeselected() {
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

    func test_itemHighlighted() {
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

    func test_itemUnhighlighted() {
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

    func test_willDisplayCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultCell: UICollectionViewCell? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.willDisplayCell
            .subscribe(onNext: {
                let (cell, indexPath) = $0
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

    func test_willDisplaySupplementaryView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultSupplementaryView: UICollectionReusableView? = nil
        var resultElementKind: String? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.willDisplaySupplementaryView
            .subscribe(onNext: {
                let (reuseableView, elementKind, indexPath) = $0

                resultSupplementaryView = reuseableView
                resultElementKind = elementKind
                resultIndexPath = indexPath
            })

        let testSupplementaryView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        #if swift(>=4.2)
            let testElementKind = UICollectionView.elementKindSectionHeader
        #else
            let testElementKind = UICollectionElementKindSectionHeader
        #endif
        let testIndexPath = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, willDisplaySupplementaryView: testSupplementaryView, forElementKind: testElementKind, at: testIndexPath)

        XCTAssertEqual(resultSupplementaryView, testSupplementaryView)
        XCTAssertEqual(resultElementKind, testElementKind)
        XCTAssertEqual(resultIndexPath, testIndexPath)
        subscription.dispose()
    }

    func test_didEndDisplayingCell() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultCell: UICollectionViewCell? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.didEndDisplayingCell
            .subscribe(onNext: {
                let (cell, indexPath) = $0
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

    func test_didEndDisplayingSupplementaryView() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var resultSupplementaryView: UICollectionReusableView? = nil
        var resultElementKind: String? = nil
        var resultIndexPath: IndexPath? = nil

        let subscription = collectionView.rx.didEndDisplayingSupplementaryView
            .subscribe(onNext: {
                let (reuseableView, elementKind, indexPath) = $0
                resultSupplementaryView = reuseableView
                resultElementKind = elementKind
                resultIndexPath = indexPath
            })

        let testSupplementaryView = UICollectionReusableView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        #if swift(>=4.2)
            let testElementKind = UICollectionView.elementKindSectionHeader
        #else
            let testElementKind = UICollectionElementKindSectionHeader
        #endif
        let testIndexPath = IndexPath(row: 1, section: 0)
        collectionView.delegate!.collectionView!(collectionView, didEndDisplayingSupplementaryView: testSupplementaryView, forElementOfKind: testElementKind, at: testIndexPath)

        XCTAssertEqual(resultSupplementaryView, testSupplementaryView)
        XCTAssertEqual(resultElementKind, testElementKind)
        XCTAssertEqual(resultIndexPath, testIndexPath)
        subscription.dispose()
    }

    @available(iOS 10.0, tvOS 10.0, *)
    func test_prefetchItems() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var indexPaths: [IndexPath] = []

        let subscription = collectionView.rx.prefetchItems
            .subscribe(onNext: {
                indexPaths = $0
            })

        let testIndexPaths = [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)]
        collectionView.prefetchDataSource!.collectionView(collectionView, prefetchItemsAt: testIndexPaths)

        XCTAssertEqual(indexPaths, testIndexPaths)
        subscription.dispose()
    }

    @available(iOS 10.0, tvOS 10.0, *)
    func test_cancelPrefetchingForItems() {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout)

        var indexPaths: [IndexPath] = []

        let subscription = collectionView.rx.cancelPrefetchingForItems
            .subscribe(onNext: {
                indexPaths = $0
            })

        let testIndexPaths = [IndexPath(item: 1, section: 0), IndexPath(item: 2, section: 0)]
        collectionView.prefetchDataSource!.collectionView!(collectionView, cancelPrefetchingForItemsAt: testIndexPaths)

        XCTAssertEqual(indexPaths, testIndexPaths)
        subscription.dispose()
    }

    @available(iOS 10.0, tvOS 10.0, *)
    func test_PrefetchDataSourceEventCompletesOnDealloc() {
        let layout = UICollectionViewFlowLayout()
        let createView: () -> UICollectionView = { UICollectionView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), collectionViewLayout: layout) }

        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.prefetchItems }
        ensureEventDeallocated(createView) { (view: UICollectionView) in view.rx.cancelPrefetchingForItems }
    }

    func test_DelegateEventCompletesOnDealloc1() {
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

    func test_DelegateEventCompletesOnDealloc2() {
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

    func test_DelegateEventCompletesOnDealloc2_cellType() {
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

    func test_ModelSelected_itemsWithCellFactory() {
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

    func test_ModelSelected_itemsWithCellIdentifier() {
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

    func test_ModelDeselected_itemsWithCellFactory() {
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

    func test_ModelDeselected_itemsWithCellIdentifier() {
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

    func test_modelAtIndexPath_normal() {
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

    #if os(tvOS)

        func test_didUpdateFocusInContextWithAnimationCoordinator() {
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

            var resultContext: UICollectionViewFocusUpdateContext? = nil
            var resultAnimationCoordinator: UIFocusAnimationCoordinator? = nil

            let subscription = collectionView.rx.didUpdateFocusInContextWithAnimationCoordinator
                .subscribe(onNext: { args in
                    let (context, animationCoordinator) = args
                    resultContext = context
                    resultAnimationCoordinator = animationCoordinator
                })

            let context = UICollectionViewFocusUpdateContext()
            let animationCoordinator = UIFocusAnimationCoordinator()

            XCTAssertEqual(resultContext, nil)
            XCTAssertEqual(resultAnimationCoordinator, nil)

            collectionView.delegate!.collectionView!(collectionView, didUpdateFocusIn: context, with: animationCoordinator)
 
            XCTAssertEqual(resultContext, context)
            XCTAssertEqual(resultAnimationCoordinator, animationCoordinator)

            subscription.dispose()
            dataSourceSubscription.dispose()
        }
    #endif
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

    func testDataSourceIsResetOnDispose() {
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

        XCTAssertTrue(collectionView.dataSource === RxCollectionViewDataSourceProxy.proxy(for: collectionView))

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
