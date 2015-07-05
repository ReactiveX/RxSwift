//
//  UICollectionView+Rx.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import UIKit

extension UICollectionView {
    
    // factories
    
    override func rx_createDelegateProxy() -> RxScrollViewDelegateProxy {
        return RxCollectionViewDelegateProxy(parentObject: self)
    }
    
    // proxies
    
    public var rx_dataSource: DelegateProxy {
        get {
            return proxyForObject(self) as RxCollectionViewDataSourceProxy
        }
    }
    
    // data source
    
    // Registers reactive data source with collection view.
    // Difference between reactive data source and UICollectionViewDataSource is that reactive
    // has additional method:
    //
    // ```
    //     func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) -> Void
    // ```
    //
    // If you want to register non reactive data source, please use `rx_setDataSource` method
    public func rx_subscribeWithReactiveDataSource<DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>>
        (dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {
            return setProxyDataSourceForObject(self, dataSource, false) { (_: RxCollectionViewDataSourceProxy, event) -> Void in
                dataSource.collectionView(self, observedEvent: event)
            }
    }
    
    // Registers `UICollectionViewDataSource`.
    // For more detailed explanations, take a look at `RxCollectionViewDataSourceType.swift` and `DelegateProxyType.swift`
    public func rx_setDataSource(dataSource: UICollectionViewDataSource)
        -> Disposable {
        let proxy: RxCollectionViewDataSourceProxy = proxyForObject(self)
        return installDelegate(proxy, dataSource, false, onProxyForObject: self)
    }
    
    // delegate
    
    // For more detailed explanations, take a look at `DelegateProxyType.swift`
    public func rx_setDelegate(delegate: UICollectionViewDelegate)
        -> Disposable {
        let proxy: RxCollectionViewDelegateProxy = proxyForObject(self)
        return installDelegate(proxy, delegate, false, onProxyForObject: self)
    }
    
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func rx_subscribeItemsTo<Item>
        (cellFactory: (UICollectionView, NSIndexPath, Item) -> UICollectionViewCell)
        -> Observable<[Item]> -> Disposable {
            return { source in
                let dataSource = RxCollectionViewReactiveArrayDataSource<Item>(cellFactory: cellFactory)
                return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
            }
    }
    
    public func rx_subscribeItemsToWithCellIdentifier<Item, Cell: UICollectionViewCell>
        (cellIdentifier: String, configureCell: (NSIndexPath, Item, Cell) -> Void)
        -> Observable<[Item]> -> Disposable {
            return { source in
                let dataSource = RxCollectionViewReactiveArrayDataSource<Item> { (cv, indexPath, item) in
                    let cell = cv.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
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
    
    // typed events
    
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected >- map { indexPath in
            let dataSource: RxCollectionViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.getForwardToDelegate())
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
    
    // private methods
    
    private func _proxyObservableForObject<E, DisposeKey>(addObserver: (RxCollectionViewDelegateProxy, ObserverOf<E>) -> DisposeKey, removeObserver: (RxCollectionViewDelegateProxy, DisposeKey) -> Void) -> Observable<E> {
        return proxyObservableForObject(self, addObserver, removeObserver)
    }
    
    private func _dataSourceObservable<E, DisposeKey>(addObserver: (RxCollectionViewDataSourceProxy, ObserverOf<E>) -> DisposeKey,
        removeObserver: (RxCollectionViewDataSourceProxy, DisposeKey) -> Void)
        -> Observable<E> {
            return proxyObservableForObject(self, addObserver, removeObserver)
    }
}