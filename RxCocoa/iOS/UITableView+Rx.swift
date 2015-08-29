//
//  UITableView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import UIKit

// Items

extension UITableView {
    public func rx_itemsWithCellFactory<S: SequenceType, O: ObservableType where O.E == S>
        (source: O)
        (cellFactory: (UITableView, Int, S.Generator.Element) -> UITableViewCell)
        -> Disposable {
        let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)
    
        return self.rx_itemsWithDataSource(dataSource)(source: source)
    }

    public func rx_itemsWithCellIdentifier<S: SequenceType, Cell: UITableViewCell, O : ObservableType where O.E == S>
        (cellIdentifier: String)
        (source: O)
        (configureCell: (Int, S.Generator.Element, Cell) -> Void)
        -> Disposable {
        let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<S> { (tv, i, item) in
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
            configureCell(i, item, cell)
            return cell
        }
        
            return self.rx_itemsWithDataSource(dataSource)(source: source)
    }
    
    public func rx_itemsWithDataSource<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        (source: O)
        -> Disposable  {
        return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxTableViewDataSourceProxy, event) -> Void in
            guard let tableView = self else {
                return
            }
            dataSource.tableView(tableView, observedEvent: event)
        }
    }
}

extension UITableView {
 
    // factories

    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self)
    }
    
    // proxies
    
    public var rx_dataSource: DelegateProxy {
        return proxyForObject(self) as RxTableViewDataSourceProxy
    }
   
    public func rx_setDataSource(dataSource: UITableViewDataSource)
        -> Disposable {
        let proxy: RxTableViewDataSourceProxy = proxyForObject(self)
            
        return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }
    
    // events
    
    
    public var rx_itemSelected: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe("tableView:didSelectRowAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }

        return ControlEvent(source: source)
    }
 
    public var rx_itemInserted: ControlEvent<NSIndexPath> {
        let source = rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            .map { a in
                return (a[2] as! NSIndexPath)
        }
        
        return ControlEvent(source: source)
    }
    
    public var rx_itemDeleted: ControlEvent<NSIndexPath> {
        let source = rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Delete
            }
            .map { a in
                return (a[2] as! NSIndexPath)
            }
        
        return ControlEvent(source: source)
    }
    
    public var rx_itemMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = rx_dataSource.observe("tableView:moveRowAtIndexPath:toIndexPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
            }
        
        return ControlEvent(source: source)
    }
    
    // typed events
    // This method only works in case one of the `rx_subscribeItemsTo` methods was used.
    public func rx_modelSelected<T>() -> ControlEvent<T> {
        let source: Observable<T> = rx_itemSelected.map { ip in
            let dataSource: RxTableViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(ip.item)!
        }
        
        return ControlEvent(source: source)
    }
    
}