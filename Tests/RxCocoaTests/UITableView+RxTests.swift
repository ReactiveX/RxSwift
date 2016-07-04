//
//  UITableView+RxTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/8/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import XCTest

class UITableViewTests : RxTest {
    func testTableView_DelegateEventCompletesOnDealloc() {
        let createView: () -> UITableView = { UITableView(frame: CGRectMake(0, 0, 1, 1)) }

        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemSelected }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemDeselected }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemAccessoryButtonTapped }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemDeleted }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemMoved }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_itemInserted }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelDeselected(Int.self) }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_willDisplayCell }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_didEndDisplayingCell }
    }

    func testTableView_itemSelected() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil

        let subscription = tableView.rx_itemSelected
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testTableView_itemDeselected() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil

        let subscription = tableView.rx_itemDeselected
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        tableView.delegate!.tableView!(tableView, didDeselectRowAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testTableView_itemAccessoryButtonTapped() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil

        let subscription = tableView.rx_itemAccessoryButtonTapped
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        tableView.delegate!.tableView!(tableView, accessoryButtonTappedForRowWithIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testTableView_itemDeleted() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil

        let subscription = tableView.rx_itemDeleted
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        tableView.dataSource!.tableView!(tableView, commitEditingStyle: .Delete, forRowAtIndexPath:  testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testTableView_itemInserted() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil

        let subscription = tableView.rx_itemInserted
            .subscribeNext { indexPath in
                resultIndexPath = indexPath
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        tableView.dataSource!.tableView!(tableView, commitEditingStyle: .Insert, forRowAtIndexPath:  testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        subscription.dispose()
    }

    func testTableView_willDisplayCell() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil
        var resultCell: UITableViewCell? = nil

        let subscription = tableView.rx_willDisplayCell
            .subscribeNext { (cell, indexPath) in
                resultIndexPath = indexPath
                resultCell = cell
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        let testCell = UITableViewCell()
        tableView.delegate!.tableView!(tableView, willDisplayCell: testCell, forRowAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        XCTAssertEqual(resultCell, testCell)
        subscription.dispose()
    }

    func testTableView_didEndDisplayingCell() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil
        var resultCell: UITableViewCell? = nil

        let subscription = tableView.rx_didEndDisplayingCell
            .subscribeNext { (cell, indexPath) in
                resultIndexPath = indexPath
                resultCell = cell
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        let testCell = UITableViewCell()
        tableView.delegate!.tableView!(tableView, didEndDisplayingCell: testCell, forRowAtIndexPath: testRow)

        XCTAssertEqual(resultIndexPath, testRow)
        XCTAssertEqual(resultCell, testCell)
        subscription.dispose()
    }

    func testTableView_itemMoved() {
        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))

        var resultIndexPath: NSIndexPath? = nil
        var resultIndexPath2: NSIndexPath? = nil

        let subscription = tableView.rx_itemMoved
            .subscribeNext { (indexPath, indexPath2) in
                resultIndexPath = indexPath
                resultIndexPath2 = indexPath2
            }

        let testRow = NSIndexPath(forRow: 1, inSection: 0)
        let testRow2 = NSIndexPath(forRow: 1, inSection: 0)
        tableView.dataSource!.tableView!(tableView, moveRowAtIndexPath: testRow, toIndexPath: testRow2)

        XCTAssertEqual(resultIndexPath, testRow)
        XCTAssertEqual(resultIndexPath2, testRow2)
        subscription.dispose()
    }

    func testTableView_DelegateEventCompletesOnDealloc1() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellFactory) { (tv, index: Int, item: Int) -> UITableViewCell in
                return UITableViewCell(style: .Default, reuseIdentifier: "Identity")
            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_DelegateEventCompletesOnDealloc2() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_DelegateEventCompletesOnDealloc2_cellType() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a", cellType: UITableViewCell.self)) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }
        ensureEventDeallocated(createView) { (view: UITableView) in view.rx_modelSelected(Int.self) }
    }

    func testTableView_ModelSelected_rx_itemsWithCellFactory() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])
        
        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellFactory) { (tv, index: Int, item: Int) -> UITableViewCell in
                return UITableViewCell(style: .Default, reuseIdentifier: "Identity")
            }
            
            return (tableView, dataSourceSubscription)
        }
        
        let (tableView, dataSourceSubscription) = createView()
        
        var selectedItem: Int? = nil
        
        let s = tableView.rx_modelSelected(Int.self)
            .subscribeNext { item in
                selectedItem = item
        }
        
        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        
        XCTAssertEqual(selectedItem, 2)
        
        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testTableView_ModelSelected_itemsWithCellIdentifier() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = tableView.rx_modelSelected(Int.self)
            .subscribeNext { item in
                selectedItem = item
        }

        tableView.delegate!.tableView!(tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testTableView_ModelDeselected_rx_itemsWithCellFactory() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellFactory) { (tv, index: Int, item: Int) -> UITableViewCell in
                return UITableViewCell(style: .Default, reuseIdentifier: "Identity")
            }

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = tableView.rx_modelDeselected(Int.self)
            .subscribeNext { item in
                selectedItem = item
            }

        tableView.delegate!.tableView!(tableView, didDeselectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))

        XCTAssertEqual(selectedItem, 2)

        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testTableView_ModelDeselected_itemsWithCellIdentifier() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithCellIdentifier("a")) { (index: Int, item: Int, cell) in

            }

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        var selectedItem: Int? = nil

        let s = tableView.rx_modelDeselected(Int.self)
            .subscribeNext { item in
                selectedItem = item
            }

        tableView.delegate!.tableView!(tableView, didDeselectRowAtIndexPath: NSIndexPath(forRow: 1, inSection: 0))
        
        XCTAssertEqual(selectedItem, 2)
        
        dataSourceSubscription.dispose()
        s.dispose()
    }

    func testTableView_modelAtIndexPath_normal() {
        let items: Observable<[Int]> = Observable.just([1, 2, 3])

        let createView: () -> (UITableView, Disposable) = {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")
            let dataSource = SectionedViewDataSourceMock()
            let dataSourceSubscription = items.bindTo(tableView.rx_itemsWithDataSource(dataSource))

            return (tableView, dataSourceSubscription)
        }

        let (tableView, dataSourceSubscription) = createView()

        let model: Int = try! tableView.rx_modelAtIndexPath(NSIndexPath(forItem: 1, inSection: 0))

        XCTAssertEqual(model, 2)
        
        dataSourceSubscription.dispose()
    }
}

extension UITableViewTests {
    func testDataSourceIsBeingRetainedUntilDispose() {

        var dataSourceDeallocated = false

        var dataSourceSubscription: Disposable!
        autoreleasepool {
            let items: Observable<[Int]> = Observable.just([1, 2, 3])
            let dataSource = SectionedViewDataSourceMock()
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            dataSourceSubscription = items.bindTo(tableView.rx_itemsWithDataSource(dataSource))

            _ = dataSource.rx_deallocated.subscribeNext { _ in
                dataSourceDeallocated = true
            }
        }

        XCTAssert(dataSourceDeallocated == false)
        dataSourceSubscription.dispose()
        XCTAssert(dataSourceDeallocated == true)
    }

    func testDataSourceIsBeingRetainedUntilTableViewDealloc() {

        var dataSourceDeallocated = false

        autoreleasepool {
            let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
            tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")

            let items: Observable<[Int]> = Observable.just([1, 2, 3])
            let dataSource = SectionedViewDataSourceMock()
            _ = items.bindTo(tableView.rx_itemsWithDataSource(dataSource))

            _ = dataSource.rx_deallocated.subscribeNext { _ in
                dataSourceDeallocated = true
            }

            XCTAssert(dataSourceDeallocated == false)
        }
        XCTAssert(dataSourceDeallocated == true)
    }

    func testSetDataSourceUsesWeakReference() {

        var dataSourceDeallocated = false

        let tableView = UITableView(frame: CGRectMake(0, 0, 1, 1))
        tableView.registerClass(NSClassFromString("UITableViewCell"), forCellReuseIdentifier: "a")

        autoreleasepool {
            let dataSource = SectionedViewDataSourceMock()
            tableView.rx_setDataSource(dataSource)

            _ = dataSource.rx_deallocated.subscribeNext { _ in
                dataSourceDeallocated = true
            }

            XCTAssert(dataSourceDeallocated == false)
        }
        XCTAssert(dataSourceDeallocated == true)
    }
}