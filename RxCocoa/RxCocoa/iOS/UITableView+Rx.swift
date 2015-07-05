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

extension UITableView {
 
    // factories

    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxTableViewDelegateProxy(parentObject: self)
    }
    
    // proxies
    
    public var rx_dataSource: DelegateProxy {
        return proxyForObject(self) as RxTableViewDataSourceProxy
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
    
    // Registers `UITableViewDataSource`.
    // For more detailed explanations, take a look at `RxTableViewDataSourceType.swift` and `DelegateProxyType.swift`
    public func rx_setDataSource(dataSource: UITableViewDataSource)
        -> Disposable {
        let proxy: RxTableViewDataSourceProxy = proxyForObject(self)
            
        return installDelegate(proxy, dataSource, false, onProxyForObject: self)
    }
    
    // delegate 
    
    // For more detailed explanations, take a look at `DelegateProxyType.swift`
    public func rx_setDelegate(delegate: UITableViewDelegate)
        -> Disposable {
        let proxy: RxTableViewDelegateProxy = proxyForObject(self)
            
        return installDelegate(proxy, delegate, false, onProxyForObject: self)
    }
    
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func rx_subscribeItemsTo<Item>
        (cellFactory: (UITableView, NSIndexPath, Item) -> UITableViewCell)
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
            let dataSource = RxTableViewReactiveArrayDataSource<Item> { (tv, indexPath, item) in
                let cell = tv.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
                configureCell(indexPath, item, cell)
                return cell
            }

            return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
        }
    }

    // events
    
    
    public var rx_itemSelected: Observable<NSIndexPath> {
        return _proxyObservableForObject({ d, o in
            return d.addItemSelectedObserver(o)
        }, removeObserver: { (delegate, disposeKey) -> Void in
            delegate.removeItemSelectedObserver(disposeKey)
        })
    }
 
    public var rx_itemInserted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            >- filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Insert
            }
            >- map { a in
                return a[2] as! NSIndexPath
        }
    }
    
    public var rx_itemDeleted: Observable<NSIndexPath> {
        return rx_dataSource.observe("tableView:commitEditingStyle:forRowAtIndexPath:")
            >- filter { a in
                return UITableViewCellEditingStyle(rawValue: (a[1] as! NSNumber).integerValue) == .Delete
            }
            >- map { a in
                return a[2] as! NSIndexPath
            }
    }
    
    public var rx_itemMoved: Observable<ItemMovedEvent> {
        return rx_dataSource.observe("tableView:moveRowAtIndexPath:toIndexPath:")
            >- map { a in
                return (a[1] as! NSIndexPath, a[2] as! NSIndexPath)
            }
    }
    
    // typed events
    
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected >- map { indexPath in
            let dataSource: RxTableViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.getForwardToDelegate())
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
    
    // private methods
    
    private func _proxyObservableForObject<E, DisposeKey>(addObserver: (RxTableViewDelegateProxy, ObserverOf<E>) -> DisposeKey, removeObserver: (RxTableViewDelegateProxy, DisposeKey) -> Void) -> Observable<E> {
        return proxyObservableForObject(self, addObserver, removeObserver)
    }
    
    private func _createDataSourceObservable<E, DisposeKey>(addObserver: (RxTableViewDataSourceProxy, ObserverOf<E>) -> DisposeKey,
        removeObserver: (RxTableViewDataSourceProxy, DisposeKey) -> Void)
        -> Observable<E> {
        return proxyObservableForObject(self, addObserver, removeObserver)
    }
}