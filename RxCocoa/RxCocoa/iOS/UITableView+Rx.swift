//
//  UITableView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

// This cannot be a generic class because of table view objc runtime that checks for 
// implemented selectors in data source
public class RxTableViewDataSource :  NSObject, UITableViewDataSource {
    public typealias CellFactory = (UITableView, NSIndexPath, AnyObject) -> UITableViewCell
    
    public var rows: [AnyObject] {
        get {
            return _rows
        }
    }
    
    var _rows: [AnyObject]
    
    let cellFactory: CellFactory
    
    public init(cellFactory: CellFactory) {
        self._rows = []
        self.cellFactory = cellFactory
    }
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _rows.count
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row < _rows.count {
            let row = indexPath.row
            return cellFactory(tableView, indexPath, self._rows[row])
        }
        else {
            rxFatalError("something went wrong")
            let cell: UITableViewCell? = nil
            return cell!
        }
    }
}

public class RxTableViewDelegate: RxScrollViewDelegate, UITableViewDelegate {
    public typealias Observer = ObserverOf<(UITableView, Int)>
    public typealias DisposeKey = Bag<Observer>.KeyType
    
    var tableViewObservers: Bag<Observer>
    
    override public init() {
        tableViewObservers = Bag()
    }
    
    public func addTableViewObserver(observer: Observer) -> DisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        return tableViewObservers.put(observer)
    }
    
    public func removeTableViewObserver(key: DisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = tableViewObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
 
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let event = Event.Next(Box((tableView, indexPath.row)))
        
        dispatch(event, tableViewObservers)
    }
    
    deinit {
        if tableViewObservers.count > 0 {
            handleVoidObserverResult(.Error(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating table view delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}

// This is the most simple (but probably most common) way of using rx with UITableView.
extension UITableView {
    override func rx_createDelegate() -> RxScrollViewDelegate {
        return RxTableViewDelegate()
    }
    
    public func rx_subscribeRowsTo<E where E: AnyObject>
        (dataSource: RxTableViewDataSource)
        (source: Observable<[E]>)
        -> Disposable {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource != nil && self.dataSource !== dataSource {
            rxFatalError("Data source is different")
        }

        self.dataSource = dataSource
            
        let clearDataSource = AnonymousDisposable {
            if self.dataSource != nil && self.dataSource !== dataSource {
                rxFatalError("Data source is different")
            }
            
            self.dataSource = nil
        }
            
        let disposable = source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                dataSource._rows = value
                self.reloadData()
            case .Error(let error):
#if DEBUG
                rxFatalError("Something went wrong: \(error)")
#endif
            case .Completed:
                break
            }
        })
            
        return CompositeDisposable(clearDataSource, disposable)
    }
    
    public func rx_subscribeRowsTo<E where E : AnyObject>
        (cellFactory: (UITableView, NSIndexPath, E) -> UITableViewCell)
        (source: Observable<[E]>)
        -> Disposable {
            
        let dataSource = RxTableViewDataSource {
            cellFactory($0, $1, $2 as! E)
        }
            
        return self.rx_subscribeRowsTo(dataSource)(source: source)
    }
    
    public func rx_subscribeRowsToCellWithIdentifier<E, Cell where E : AnyObject, Cell: UITableViewCell>
        (cellIdentifier: String, configureCell: (UITableView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>)
        -> Disposable {
            
        let dataSource = RxTableViewDataSource {
            let cell = $0.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: $1) as! Cell
            configureCell($0, $1, $2 as! E, cell)
            return cell
        }
        
        return self.rx_subscribeRowsTo(dataSource)(source: source)
    }
    
    public func rx_rowTap() -> Observable<(UITableView, Int)> {
        _ = rx_checkTableViewDelegate()
        
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            var maybeDelegate = self.rx_checkTableViewDelegate()
            
            if maybeDelegate == nil {
                let delegate = self.rx_createDelegate() as! RxTableViewDelegate
                maybeDelegate = delegate
                self.delegate = maybeDelegate
            }
    
            let delegate = maybeDelegate!
            
            let key = delegate.addTableViewObserver(observer)
            
            return AnonymousDisposable {
                MainScheduler.ensureExecutingOnScheduler()
                
                _ = self.rx_checkTableViewDelegate()
                
                delegate.removeTableViewObserver(key)
                
                if delegate.tableViewObservers.count == 0 {
                    self.delegate = nil
                }
            }
        }
    }
    
    public func rx_elementTap<E>() -> Observable<E> {
        
        return rx_rowTap() >- map { (tableView, rowIndex) -> E in
            let maybeDataSource: RxTableViewDataSource? = self.rx_getTableViewDataSource()
            
            if maybeDataSource == nil {
                rxFatalError("To use element tap table view needs to use table view data source. You can still use `rx_observableRowTap`.")
            }
            
            let dataSource = maybeDataSource!
            
            return dataSource.rows[rowIndex] as! E
        }
    }
    
    // private methods
   
    private func rx_getTableViewDataSource() -> RxTableViewDataSource? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource == nil {
            return nil
        }
        
        let maybeDataSource = self.dataSource as? RxTableViewDataSource
        
        if maybeDataSource == nil {
            rxFatalError("View already has incompatible data source set. Please remove earlier delegate registration.")
        }
        
        return maybeDataSource!
    }
    
    private func rx_checkTableViewDataSource<E>() -> RxTableViewDataSource? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource == nil {
            return nil
        }
        
        let maybeDataSource = self.dataSource as? RxTableViewDataSource
        
        if maybeDataSource == nil {
            rxFatalError("View already has incompatible data source set. Please remove earlier delegate registration.")
        }
        
        return maybeDataSource!
    }
    
    private func rx_checkTableViewDelegate() -> RxTableViewDelegate? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.delegate == nil {
            return nil
        }
        
        let maybeDelegate = self.delegate as? RxTableViewDelegate
        
        if maybeDelegate == nil {
            rxFatalError("View already has incompatible delegate set. To use rx observable (for now) please remove earlier delegate registration.")
        }
        
        return maybeDelegate!
    }
}