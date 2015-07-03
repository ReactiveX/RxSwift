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

// This is the most simple (but probably most common) way of using rx with UICollectionView.
extension UICollectionView {
    
    // factories
    
    override public func rx_createDelegateBridge() -> RxScrollViewDelegateBridge {
        return RxCollectionViewDelegateBridge(view: self)
    }
    
    public func rx_createDataSourceBridge() -> RxCollectionViewDataSourceBridge {
        return RxCollectionViewDataSourceBridge(view: self)
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
    public func rx_subscribeWithReactiveDataSource<DataSource: RxCollectionViewReactiveDataSourceType>
        (dataSource: DataSource)
        -> Observable<DataSource.Element> -> Disposable {
            return subscribeObservableUsingDelegateBridgeAndDataSource(self, dataSource, { (_: RxCollectionViewDataSourceBridge, event) -> Void in
                dataSource.collectionView(self, observedEvent: event)
            })
    }
    
    // Registers `RxCollectionViewDataSourceType`.
    // For more detailed explanations, take a look at `RxCollectionViewDataSourceType.swift` and `DelegateBridgeType.swift`
    public func rx_setDataSource(dataSource: RxCollectionViewDataSourceType)
        -> Disposable {
            let result: BridgeDisposablePair<RxCollectionViewDataSourceBridge> = installDelegateOnBridge(self, dataSource)
            
            return result.disposable
    }
    
    // Registers `UICollectionViewDataSource`.
    // For more detailed explanations, take a look at `RxCollectionViewDataSourceType.swift` and `DelegateBridgeType.swift`
    public func rx_setDataSource(dataSource: UICollectionViewDataSource, retainDataSource: Bool)
        -> Disposable {
            let converter = RxCollectionViewDataSourceConverter(dataSource: dataSource, retainDataSource: retainDataSource)
            let result: BridgeDisposablePair<RxCollectionViewDataSourceBridge> = installDelegateOnBridge(self, dataSource)
            
            return result.disposable
    }
    
    // delegate
    
    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    // Retains delegate
    public func rx_setDelegate(delegate: RxCollectionViewDelegateType) -> Disposable {
        let result: BridgeDisposablePair<RxCollectionViewDelegateBridge> = installDelegateOnBridge(self, delegate)
        
        return result.disposable
    }
    
    // For more detailed explanations, take a look at `DelegateBridgeType.swift`
    public func rx_setDelegate(delegate: UICollectionViewDelegate, retainDelegate: Bool)
        -> Disposable {
            let converter = RxCollectionViewDelegateConverter(delegate: delegate, retainDelegate: retainDelegate)
            let result: BridgeDisposablePair<RxCollectionViewDelegateBridge> = installDelegateOnBridge(self, converter)
            
            return result.disposable
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
    
    public func rx_selectedItem() -> Observable<ItemSelectedEvent<UICollectionView>> {
        return createDelegateObservable({ d, o in
            return d.addItemSelectedObserver(o)
            }, removeObserver: { (delegate, disposeKey) -> Void in
                delegate.removeItemSelectedObserver(disposeKey)
        })
    }
    
    // typed events
    
    public func rx_selectedModel<T>() -> Observable<T> {
        return rx_selectedItem() >- map { e in
            let indexPath = e.indexPath
            
            let bridge = RxCollectionViewDataSourceBridge.getBridgeForView(self)!
            
            let dataSource: RxCollectionViewReactiveArrayDataSource<T> = castOrFatalError(bridge.getDelegate())
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
    
    // private methods
    
    private func createDelegateObservable<E, DisposeKey>(addObserver: (RxCollectionViewDelegateBridge, ObserverOf<E>) -> DisposeKey, removeObserver: (RxCollectionViewDelegateBridge, DisposeKey) -> Void) -> Observable<E> {
        return createObservableUsingDelegateBridge(self, addObserver, removeObserver)
    }
    
    private func createDataSourceObservable<E, DisposeKey>(addObserver: (RxCollectionViewDataSourceBridge, ObserverOf<E>) -> DisposeKey,
        removeObserver: (RxCollectionViewDataSourceBridge, DisposeKey) -> Void)
        -> Observable<E> {
            return createObservableUsingDelegateBridge(self, addObserver, removeObserver)
    }
}