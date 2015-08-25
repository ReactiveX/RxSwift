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


extension ObservableType {
    // data source
    
    // Registers reactive data source with table view.
    // Difference between reactive data source and UITableViewDataSource is that reactive
    // has additional method:
    //
    // ```
    //     func tableView(tableView: UITableView, observedEvent: Event<Element>) -> Void
    // ```
    //
    // If you want to register non reactive data source, please use `rx_setDataSource` method
    public func subscribe<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource> where E == DataSource.Element>(tableView: UITableView, withReactiveDataSource dataSource: DataSource)
        -> Disposable {
        return self.subscribeProxyDataSourceForObject(tableView, dataSource: dataSource, retainDataSource: false) { (_: RxTableViewDataSourceProxy, event) -> Void in
            dataSource.tableView(tableView, observedEvent: event)
        }
    }
}

extension ObservableType where E: SequenceType {
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func subscribeItemsOf(tableView: UITableView, cellFactory: (UITableView, Int, E.Generator.Element) -> UITableViewCell)
        -> Disposable {
        let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<E>(cellFactory: cellFactory)
        return self.subscribe(tableView, withReactiveDataSource: dataSource)
    }
    
    public func subscribeItemsOf<Cell: UITableViewCell>(tableView: UITableView, withCellIdentifier cellIdentifier: String, configureCell: (Int, E.Generator.Element, Cell) -> Void)
        -> Disposable {
        let dataSource = RxTableViewReactiveArrayDataSourceSequenceWrapper<E> { (tv, i, item) in
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
            configureCell(i, item, cell)
            return cell
        }
        
        return self.subscribe(tableView, withReactiveDataSource: dataSource)
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
    
    
    public var rx_itemSelected: Observable<NSIndexPath> {
        return rx_delegate.observe("tableView:didSelectRowAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }
    }
 
    public var rx_itemInserted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            .map { a in
                return (a[2] as! NSIndexPath)
        }
    }
    
    public var rx_itemDeleted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Delete
            }
            .map { a in
                return (a[2] as! NSIndexPath)
            }
    }
    
    public var rx_itemMoved: Observable<ItemMovedEvent> {
        return rx_dataSource.observe("tableView:moveRowAtIndexPath:toIndexPath:")
            .map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
            }
    }
    
    // typed events
    // This method only works in case one of the `rx_subscribeItemsTo` methods was used.
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected .map { ip in
            let dataSource: RxTableViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(ip.item)!
        }
    }
    
}