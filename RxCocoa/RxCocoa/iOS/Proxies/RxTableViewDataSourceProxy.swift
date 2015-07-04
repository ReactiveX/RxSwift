//
//  RxTableViewDataSourceProxy.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

// Please take a look at `DelegateProxyType.swift`
public class RxTableViewDataSourceProxy : Delegate
                                        , UITableViewDataSource
                                        , DelegateProxyType {
    
    public typealias InsertItemObserver = ObserverOf<InsertItemEvent<UITableView>>
    public typealias DeleteItemObserver = ObserverOf<DeleteItemEvent<UITableView>>
    public typealias MoveItemObserver = ObserverOf<MoveItemEvent<UITableView>>
    
    public typealias InsertItemDisposeKey = Bag<InsertItemObserver>.KeyType
    public typealias DeleteItemDisposeKey = Bag<DeleteItemObserver>.KeyType
    public typealias MoveItemDisposeKey = Bag<MoveItemObserver>.KeyType
    
    var insertItemObservers: Bag<InsertItemObserver>?
    var deleteItemObservers: Bag<DeleteItemObserver>?
    var moveItemObservers: Bag<MoveItemObserver>?
    
    public let tableView: UITableView
    
    var dataSource: UITableViewDataSource?
    
    public init(view: UITableView) {
        self.tableView = view
        super.init()
    }

    // add
    
    public func addInsertItemObserver(observer: InsertItemObserver) -> InsertItemDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        if insertItemObservers == nil {
            insertItemObservers = Bag()
        }
        
        return insertItemObservers!.put(observer)
    }
    
    public func addDeleteItemObserver(observer: DeleteItemObserver) -> DeleteItemDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        if deleteItemObservers == nil {
            deleteItemObservers = Bag()
        }
        
        return deleteItemObservers!.put(observer)
    }
    
    public func addMoveItemObserver(observer: MoveItemObserver) -> MoveItemDisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        if moveItemObservers == nil {
            moveItemObservers = Bag()
        }
        
        return moveItemObservers!.put(observer)
    }
    
    // remove
    
    public func removeInsertItemObserver(key: InsertItemDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = insertItemObservers!.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    public func removeDeleteItemObserver(key: DeleteItemDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = deleteItemObservers!.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    public func removeMoveItemObserver(key: MoveItemDisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = moveItemObservers!.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    // generic methods
    
    public func commitEditingStyle(editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Insert:
            dispatchNext(InsertItemEvent<UITableView>(view: tableView, indexPath: indexPath), insertItemObservers)
        case .Delete:
            dispatchNext(DeleteItemEvent<UITableView>(view: tableView, indexPath: indexPath), deleteItemObservers)
        case .None:
            break
        }
    }
    
    public func moveRowAtIndexPath(sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        dispatchNext(MoveItemEvent<UITableView>(view: tableView, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath), moveItemObservers)
    }
    
    // data source delegate
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.dataSource!.numberOfSectionsInTableView?(tableView) ?? 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource!.tableView(tableView, numberOfRowsInSection: section)
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return self.dataSource!.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    // proxy
    
    public class func createProxyForView(view: UIView) -> Self {
        let tableView = view as! UITableView
        return castOrFatalError(tableView.rx_createDataSourceProxy())
    }
    
    public class func getProxyForView(view: UIView) -> Self? {
        let tableView = view as! UITableView
        return castOptionalOrFatalError(tableView.dataSource)
    }
    
    // tried using `Self` instead of Any object, didn't work out
    public class func setProxyToView(view: UIView, proxy: AnyObject) {
        let tableView = view as! UITableView
        tableView.dataSource = castOptionalOrFatalError(proxy)
    }
    
    public func setDelegate(delegate: AnyObject?) {
        dataSource = castOptionalOrFatalError(delegate)
    }
    
    public func getDelegate() -> AnyObject? {
        return dataSource
    }
    
    override public func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        return dataSource
    }
    
    override public func respondsToSelector(aSelector: Selector) -> Bool {
        return super.respondsToSelector(aSelector) || (self.dataSource?.respondsToSelector(aSelector) ?? false)
    }
    
    // disposable
    
    override public var isDisposable: Bool {
        get {
            return super.isDisposable
            && self.dataSource == nil
            && insertItemObservers?.count ?? 0 == 0
            && deleteItemObservers?.count ?? 0 == 0
            && moveItemObservers?.count ?? 0 == 0
        }
    }

    override public func dispose() {
        super.dispose()
        assert(tableView.dataSource == nil || tableView.dataSource === self)
        tableView.dataSource = nil
    }
}