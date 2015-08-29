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

// Items

extension UICollectionView {
    
    public func rx_itemsWithCellFactory<S: SequenceType, O: ObservableType where O.E == S>
        (source: O)
        (cellFactory: (UICollectionView, Int, S.Generator.Element) -> UICollectionViewCell)
        -> Disposable {
        let dataSource = RxCollectionViewReactiveArrayDataSourceSequenceWrapper<S>(cellFactory: cellFactory)
        return self.rx_itemsWithDataSource(dataSource)(source: source)
    }
    
    public func rx_itemsWithCellIdentifier<S: SequenceType, Cell: UICollectionViewCell, O : ObservableType where O.E == S>
        (cellIdentifier: String)
        (source: O)
        (configureCell: (Int, S.Generator.Element, Cell) -> Void)
        -> Disposable {
        let dataSource = RxCollectionViewReactiveArrayDataSourceSequenceWrapper<S> { (cv, i, item) in
            let indexPath = NSIndexPath(forItem: i, inSection: 0)
            let cell = cv.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: indexPath) as! Cell
            configureCell(i, item, cell)
            return cell
        }
        
        return self.rx_itemsWithDataSource(dataSource)(source: source)
    }
    
    public func rx_itemsWithDataSource<DataSource: protocol<RxCollectionViewDataSourceType, UICollectionViewDataSource>, S: SequenceType, O: ObservableType where DataSource.Element == S, O.E == S>
        (dataSource: DataSource)
        (source: O)
        -> Disposable  {
        return source.subscribeProxyDataSourceForObject(self, dataSource: dataSource, retainDataSource: false) { [weak self] (_: RxCollectionViewDataSourceProxy, event) -> Void in
            guard let collectionView = self else {
                return
            }
            dataSource.collectionView(collectionView, observedEvent: event)
        }
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
    
    public var rx_itemSelected: ControlEvent<NSIndexPath> {
        let source = rx_delegate.observe("collectionView:didSelectItemAtIndexPath:")
            .map { a in
                return a[1] as! NSIndexPath
            }
        
        return ControlEvent(source: source)
    }
    
    // typed events
    
    public func rx_modelSelected<T>() -> ControlEvent<T> {
        let source: Observable<T> = rx_itemSelected .map { indexPath in
            let dataSource: RxCollectionViewReactiveArrayDataSource<T> = castOrFatalError(self.rx_dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx_subscribeItemsTo` methods was used.")
            
            return dataSource.modelAtIndex(indexPath.item)!
        }
        
        return ControlEvent(source: source)
    }
}
