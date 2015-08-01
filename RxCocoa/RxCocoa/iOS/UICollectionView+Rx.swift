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
        return installDelegate(proxy, dataSource, false, onProxyForObject: self)
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
   
    // `reloadData` - items subscription methods (it's assumed that there is one section, and it is typed `Void`)
    
    public func rx_subscribeItemsTo<Item>
        (cellFactory: (UICollectionView, Int, Item) -> UICollectionViewCell)
        -> Observable<[Item]> -> Disposable {
            return { source in
                let dataSource = RxCollectionViewReactiveArrayDataSource<Item>(cellFactory: cellFactory)
                return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
            }
    }
    
    public func rx_subscribeItemsToWithCellIdentifier<Item, Cell: UICollectionViewCell>
        (cellIdentifier: String, configureCell: (Int, Item, Cell) -> Void)
        -> Observable<[Item]> -> Disposable {
            return { source in
                let dataSource = RxCollectionViewReactiveArrayDataSource<Item> { (cv, i, item) in
                    let indexPath = NSIndexPath(forItem: i, inSection: 0)
                    let cell = cv.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
                    configureCell(i, item, cell)
                    return cell
                }
                
                return self.rx_subscribeWithReactiveDataSource(dataSource)(source)
            }
    }
    
    // events
    
    public var rx_itemSelected: Observable<NSIndexPath> {
        return rx_delegate.observe("collectionView:didSelectItemAtIndexPath:")
            >- map { a in
                return a[1] as! NSIndexPath
            }
    }
    
    // typed events
    
    public func rx_modelSelected<T>() -> Observable<T> {
        return rx_itemSelected >- map { indexPath in
            let dataSource: RxCollectionViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
    }
}

// deprecated
extension UICollectionView {
    @availability(*, deprecated=1.7, message="Replaced by `rx_subscribeItemsToWithCellIdentifier`")
    public func rx_subscribeItemsWithIdentifierTo<E, Cell where E : AnyObject, Cell : UICollectionViewCell>
        (cellIdentifier: String, configureCell: (UICollectionView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>)
        -> Disposable {
        let l = rx_subscribeItemsToWithCellIdentifier(cellIdentifier) { (i: Int, e: E, cell: Cell) in
            return configureCell(self, NSIndexPath(forItem: i, inSection: 0), e, cell)
        }
            
        return l(source)
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_itemSelected`")
    public func rx_itemTap() -> Observable<(UICollectionView, Int)> {
        return rx_itemSelected
            >- map { i in
                return (self, i.item)
            }
    }
    
    @availability(*, deprecated=1.7, message="Replaced by `rx_modelSelected`")
    public func rx_elementTap<E>() -> Observable<E> {
        return rx_modelSelected()
    }
}