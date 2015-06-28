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

    public func rx_createDataSourceBridge() -> RxTableViewDataSourceBridge {
        return RxTableViewDataSourceBridge(view: self)
    }
    
    public override func rx_createDelegateBridge() -> RxScrollViewDelegateBridge {
        return RxTableViewDelegateBridgeWithProxyFiltering(view: self)
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
    public func rx_subscribeWithReactiveDataSource<DataSource: RxTableViewReactiveDataSourceType>
        (dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {
        return subscribeObservableUsingDelegateBridgeAndDataSource(self, dataSource, { (_: RxTableViewDataSourceBridge, event) -> Void in
            dataSource.tableView(self, observedEvent: event)
        })
    }
    
    // Registers `RxTableViewDataSourceType`.
    // For more detailed explanations, take a look at `RxTableViewDataSourceType.swift` and `DelegateBridgeType.swift`
    public func rx_setDataSource(dataSource: RxTableViewDataSourceType)
        -> Disposable {
        let result: BridgeDisposablePair<RxTableViewDataSourceBridge> = installDelegateOnBridge(self, dataSource)
            
        return result.disposable
    }

    // Registers `UITableViewDataSource`.
    // For more detailed explanations, take a look at `RxTableViewDataSourceType.swift` and `DelegateBridgeType.swift`
    public func rx_setDataSource(dataSource: UITableViewDataSource, retainDataSource: Bool)
        -> Disposable {
            let converter = RxTableViewDataSourceConverter(dataSource: dataSource, retainDataSource: retainDataSource)
        let result: BridgeDisposablePair<RxTableViewDataSourceBridge> = installDelegateOnBridge(self, dataSource)
            
        return result.disposable
    }
    
    // delegate 
    
    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    // Retains delegate
    public func rx_setDelegate(delegate: RxTableViewDelegateType) -> Disposable {
        let result: BridgeDisposablePair<RxTableViewDelegateBridge> = installDelegateOnBridge(self, delegate)
        
        return result.disposable
    }
    
    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    public func rx_setDelegate(delegate: UITableViewDelegate, retainDelegate: Bool)
        -> Disposable {
            let converter = RxTableViewDelegateConverter(delegate: delegate, retainDelegate: retainDelegate)
            let result: BridgeDisposablePair<RxTableViewDelegateBridge> = installDelegateOnBridge(self, converter)
            
            return result.disposable
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
    
    public func rx_selectedItem() -> Observable<ItemSelectedEvent<UITableView>> {
        return createDelegateObservable({ d, o in
            return d.addItemSelectedObserver(o)
        }, removeObserver: { (delegate, disposeKey) -> Void in
            delegate.removeItemSelectedObserver(disposeKey)
        })
    }
    
    public func rx_deleteItem() -> Observable<DeleteItemEvent<UITableView>> {
        return createDataSourceObservable({ d, o in
            return d.addDeleteItemObserver(o)
            }, removeObserver: { (dataSource, disposeKey) -> () in
                dataSource.removeDeleteItemObserver(disposeKey)
        })
    }
    
    public func rx_moveItem() -> Observable<MoveItemEvent<UITableView>> {
        return createDataSourceObservable({ d, o in
            return d.addMoveItemObserver(o)
            }, removeObserver: { (dataSource, disposeKey) -> () in
                dataSource.removeMoveItemObserver(disposeKey)
        })
    }
    
    // typed events
    
    public func rx_selectedModel<T>() -> Observable<T> {
        return rx_selectedItem() >- map { e in
            let indexPath = e.indexPath
            
            let bridge = RxTableViewDataSourceBridge.getBridgeForView(self)!
            
            let dataSource: RxTableViewReactiveArrayDataSource<T> = castOrFatalError(bridge.getDelegate())
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
    
    // private methods
    
    private func createDelegateObservable<E, DisposeKey>(addObserver: (RxTableViewDelegateBridge, ObserverOf<E>) -> DisposeKey, removeObserver: (RxTableViewDelegateBridge, DisposeKey) -> Void) -> Observable<E> {
        return createObservableUsingDelegateBridge(self, addObserver, removeObserver)
    }
    
    private func createDataSourceObservable<E, DisposeKey>(addObserver: (RxTableViewDataSourceBridge, ObserverOf<E>) -> DisposeKey,
        removeObserver: (RxTableViewDataSourceBridge, DisposeKey) -> Void)
        -> Observable<E> {
        return createObservableUsingDelegateBridge(self, addObserver, removeObserver)
    }
}