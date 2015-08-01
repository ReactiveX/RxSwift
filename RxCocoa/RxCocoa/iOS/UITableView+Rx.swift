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
            
        return installDelegate(proxy, dataSource, false, onProxyForObject: self)
    }
    
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
    public func rx_subscribeWithReactiveDataSource<DataSource: protocol<RxTableViewDataSourceType, UITableViewDataSource>>
        (dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {
        return setProxyDataSourceForObject(self, dataSource, false) { (_: RxTableViewDataSourceProxy, event) -> Void in
            dataSource.tableView(self, observedEvent: event)
        }
    }
    
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func rx_subscribeItemsTo<Item>
        (cellFactory: (UITableView, Int, Item) -> UITableViewCell)
        -> Observable<[Item]> -> Disposable {
        return { source in
            let dataSource = RxTableViewReactiveArrayDataSource<Item>(cellFactory: cellFactory)
            
            return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
        }
    }
    
    public func rx_subscribeItemsToWithCellIdentifier<Item, Cell: UITableViewCell>
        (cellIdentifier: String, configureCell: (NSIndexPath, Item, Cell) -> Void)
        -> Observable<[Item]> -> Disposable {
        return { source in
            let dataSource = RxTableViewReactiveArrayDataSource<Item> { (tv, i, item) in
                let indexPath = NSIndexPath(forItem: i, inSection: 0)
                let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
                configureCell(indexPath, item, cell)
                return cell
            }

            return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
        }
    }

    // events
    
    
    public var rx_itemSelected: Observable<NSIndexPath> {
        return rx_delegate.observe("tableView:didSelectRowAtIndexPath:")
            >- map { a in
                return a[1] as! NSIndexPath
            }
    }
 
    public var rx_itemInserted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            >- filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            >- map { a in
                return (a[2] as! NSIndexPath)
        }
    }
    
    public var rx_itemDeleted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            >- filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Delete
            }
            >- map { a in
                return (a[2] as! NSIndexPath)
            }
    }
    
    public var rx_itemMoved: Observable<ItemMovedEvent> {
        return rx_dataSource.observe("tableView:moveRowAtIndexPath:toIndexPath:")
            >- map { a in
                return ((a[1] as! NSIndexPath), (a[2] as! NSIndexPath))
            }
    }
    
    // typed events
    // This method only works in case one of the `rx_subscribeItemsTo` methods was used.
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected >- map { ip in
            let dataSource: RxTableViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(ip.item)!
        }
    }
    
}

// deprecated
extension UITableView {
    @availability(*, deprecated=1.7, message="Replaced by `rx_subscribeWithReactiveDataSource`")
    public func rx_subscribeRowsTo<E where E: AnyObject>
        (dataSource: UITableViewDataSource)
        (source: Observable<[E]>)
        -> Disposable {
        return rx_setDataSource(dataSource)
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_setDataSource`")
    public func rx_subscribeRowsTo<E where E : AnyObject>
        (cellFactory: (UITableView, NSIndexPath, E) -> UITableViewCell)
        (source: Observable<[E]>)
        -> Disposable {
        let l = rx_subscribeItemsTo { (tv: UITableView, i: Int, e: E) -> UITableViewCell in
            return cellFactory(tv, NSIndexPath(forItem: i, inSection: 0), e)
        }
            
        return l(source)
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_subscribeItemsToWithCellIdentifier`")
    public func rx_subscribeRowsToCellWithIdentifier<E, Cell where E : AnyObject, Cell: UITableViewCell>
        (cellIdentifier: String, configureCell: (UITableView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>)
        -> Disposable {
        let l = rx_subscribeItemsToWithCellIdentifier(cellIdentifier) { (ip: NSIndexPath, e: E, c: Cell) -> Void in
            configureCell(self, ip, e, c)
        }
        return l(source)
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_itemSelected`")
    public func rx_rowTap() -> Observable<(UITableView, Int)> {
        return rx_itemSelected
            >- map { ip in
                return (self, ip.item)
            }
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_modelSelected`")
    public func rx_elementTap<E>() -> Observable<E> {
        return rx_modelSelected()
    }
}