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

// This cannot be a generic class because of collection view objc runtime that checks for
// implemented selectors in data source
public class RxCollectionViewDataSource :  NSObject, UICollectionViewDataSource {
    public typealias CellFactory = (UICollectionView, NSIndexPath, AnyObject) -> UICollectionViewCell
    
    public var items: [AnyObject] {
        get {
            return _items
        }
    }
    
    var _items: [AnyObject]
    
    let cellFactory: CellFactory
    
    public init(cellFactory: CellFactory) {
        self._items = []
        self.cellFactory = cellFactory
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _items.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.item < _items.count {
            return cellFactory(collectionView, indexPath, self._items[indexPath.item])
        }
        else {
            rxFatalError("something went wrong")
            let cell: UICollectionViewCell? = nil
            return cell!
        }
    }
}

public class RxCollectionViewDelegate: RxScrollViewDelegate, UICollectionViewDelegate {
    public typealias Observer = ObserverOf<(UICollectionView, Int)>
    public typealias DisposeKey = Bag<Observer>.KeyType
    
    var collectionViewObservers: Bag<Observer>
    
    override public init() {
        collectionViewObservers = Bag()
    }
    
    public func addCollectionViewObserver(observer: Observer) -> DisposeKey {
        MainScheduler.ensureExecutingOnScheduler()
        
        return collectionViewObservers.put(observer)
    }
    
    public func removeCollectionViewObserver(key: DisposeKey) {
        MainScheduler.ensureExecutingOnScheduler()
        
        let element = collectionViewObservers.removeKey(key)
        if element == nil {
            removingObserverFailed()
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        let event = Event.Next(Box((collectionView, indexPath.item)))
        
        dispatch(event, collectionViewObservers)
    }
    
    deinit {
        if collectionViewObservers.count > 0 {
            handleVoidObserverResult(.Error(rxError(RxCocoaError.InvalidOperation, "Something went wrong. Deallocating collection view delegate while there are still subscribed observers means that some subscription was left undisposed.")))
        }
    }
}

// This is the most simple (but probably most common) way of using rx with UICollectionView.
extension UICollectionView {
    override func rx_createDelegate() -> RxScrollViewDelegate {
        return RxCollectionViewDelegate()
    }
    
    public func rx_subscribeItemsTo<E where E: AnyObject>
        (dataSource: RxCollectionViewDataSource)
        (source: Observable<[E]>)
        -> Disposable {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource != nil && self.dataSource !== dataSource {
            rxFatalError("Data source is different")
        }
        
        self.dataSource = dataSource
        
        let clearDataSource = AnonymousDisposable {
            if self.dataSource != nil && self.dataSource !== dataSource {
                rxFatalError("Data source is different")
            }
            
            self.dataSource = nil
        }
        
        let disposable = source.subscribe(AnonymousObserver { event in
            MainScheduler.ensureExecutingOnScheduler()
            
            switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                dataSource._items = value
                self.reloadData()
            case .Error(let error):
#if DEBUG
                rxFatalError("Something went wrong: \(error)")
#endif
                break
            case .Completed:
                break
            }
        })
        
        return CompositeDisposable(clearDataSource, disposable)
    }

    public func rx_subscribeItemsTo<E where E : AnyObject>
        (cellFactory: (UICollectionView, NSIndexPath, E) -> UICollectionViewCell)
        (source: Observable<[E]>)
        -> Disposable {
            
        let dataSource = RxCollectionViewDataSource(cellFactory: {
            cellFactory($0, $1, $2 as! E)
        })
        
        return self.rx_subscribeItemsTo(dataSource)(source: source)
    }
    
    public func rx_subscribeItemsWithIdentifierTo<E, Cell where E : AnyObject, Cell : UICollectionViewCell>
        (cellIdentifier: String, configureCell: (UICollectionView, NSIndexPath, E, Cell) -> Void)
        (source: Observable<[E]>)
        -> Disposable {
            
        let dataSource = RxCollectionViewDataSource {
            let cell = $0.dequeueReusableCellWithReuseIdentifier(cellIdentifier, forIndexPath: $1) as! Cell
            configureCell($0, $1, $2 as! E, cell)
            
            return cell
        }
        
        return self.rx_subscribeItemsTo(dataSource)(source: source)
    }
    
    
    public func rx_itemTap() -> Observable<(UICollectionView, Int)> {
        _ = rx_checkCollectionViewDelegate()
        
        return AnonymousObservable { observer in
            MainScheduler.ensureExecutingOnScheduler()
            
            var maybeDelegate = self.rx_checkCollectionViewDelegate()
            
            if maybeDelegate == nil {
                let delegate = self.rx_createDelegate() as! RxCollectionViewDelegate
                maybeDelegate = delegate
                self.delegate = maybeDelegate
            }
            
            let delegate = maybeDelegate!
            
            let key = delegate.addCollectionViewObserver(observer)
            
            return AnonymousDisposable {
                MainScheduler.ensureExecutingOnScheduler()
                
                _ = self.rx_checkCollectionViewDelegate()
                
                delegate.removeCollectionViewObserver(key)
                
                if delegate.collectionViewObservers.count == 0 {
                    self.delegate = nil
                }
            }
        }
    }
    
    public func rx_elementTap<E>() -> Observable<E> {
        
        return rx_itemTap() >- map { (tableView, rowIndex) -> E in
            let maybeDataSource: RxCollectionViewDataSource? = self.rx_collectionViewDataSource()
            
            if maybeDataSource == nil {
                rxFatalError("To use element tap table view needs to use table view data source. You can still use `rx_observableItemTap`.")
            }
            
            let dataSource = maybeDataSource!
            
            return dataSource.items[rowIndex] as! E
        }
    }
    
    // private methods
    
    private func rx_collectionViewDataSource() -> RxCollectionViewDataSource? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource == nil {
            return nil
        }
        
        let maybeDataSource = self.dataSource as? RxCollectionViewDataSource
        
        if maybeDataSource == nil {
            rxFatalError("View already has incompatible data source set. Please remove earlier delegate registration.")
        }
        
        return maybeDataSource!
    }
    
    private func rx_checkCollectionViewDataSource<E>() -> RxCollectionViewDataSource? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.dataSource == nil {
            return nil
        }
        
        let maybeDataSource = self.dataSource as? RxCollectionViewDataSource
        
        if maybeDataSource == nil {
            rxFatalError("View already has incompatible data source set. Please remove earlier delegate registration.")
        }
        
        return maybeDataSource!
    }
    
    private func rx_checkCollectionViewDelegate() -> RxCollectionViewDelegate? {
        MainScheduler.ensureExecutingOnScheduler()
        
        if self.delegate == nil {
            return nil
        }
        
        let maybeDelegate = self.delegate as? RxCollectionViewDelegate
        
        if maybeDelegate == nil {
            rxFatalError("View already has incompatible delegate set. To use rx observable (for now) please remove earlier delegate registration.")
        }
        
        return maybeDelegate!
    }
}