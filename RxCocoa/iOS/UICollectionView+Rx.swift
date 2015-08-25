//
//  UICollectionView+Rx.swift
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
    
    // Registers reactive data source with collection view.
    // Difference between reactive data source and UICollectionViewDataSource is that reactive
    // has additional method:
    //
    // ```
    //     func collectionView(collectionView: UICollectionView, observedEvent: Event<Element>) -> Void
    // ```
    //
    // If you want to register non reactive data source, please use `rx_setDataSource` method
    public func subscribe<DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource> where E == DataSource.Element>(collectionView: UICollectionView, withReactiveDataSource dataSource: DataSource)
        -> Disposable {
        return self.subscribeProxyDataSourceForObject(collectionView, dataSource: dataSource, retainDataSource: false) { (_: RxCollectionViewDataSourceProxy, event) -> Void in
            dataSource.collectionView(collectionView, observedEvent: event)
        }
    }
}

extension ObservableType where E: SequenceType {
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func subscribeItemsOf(collectionView: UICollectionView, cellFactory: (UICollectionView, Int, E.Generator.Element) -> UICollectionViewCell)
        -> Disposable {
        let dataSource = RxCollectionViewReactiveArrayDataSourceSequenceWrapper<E>(cellFactory: cellFactory)
        return self.subscribe(collectionView, withReactiveDataSource: dataSource)
    }
    
    public func subscribeItemsOf<Cell: UICollectionViewCell>(collectionView: UICollectionView, withCellIdentifier cellIdentifier: String, configureCell: (Int, E.Generator.Element, Cell) -> Void)
        -> Disposable {
        let dataSource = RxCollectionViewReactiveArrayDataSourceSequenceWrapper<E> { (cv, i, item) in
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = cv.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
            configureCell(i, item, cell)
            return cell
        }
        
        return self.subscribe(collectionView, withReactiveDataSource: dataSource)
    }
}

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
    
    // For more detailed explanations, take a look at `DelegateProxyType.swift`
    public func rx_setDataSource(dataSource: UICollectionViewDataSource)
        -> Disposable {
        let proxy: RxCollectionViewDataSourceProxy = proxyForObject(self)
        return installDelegate(proxy, delegate: dataSource, retainDelegate: false, onProxyForObject: self)
    }
   
    // events
    
    public var rx_itemSelected: Observable<NSIndexPath> {
        return rx_delegate.observe("collectionView:didSelectItemAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }
    }
    
    // typed events
    
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected .map { indexPath in
            let dataSource: RxCollectionViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
}
