//
//  RxCollectionViewSectionedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
    
public class _RxCollectionViewSectionedDataSource : NSObject
                                                  , UICollectionViewDataSource {
    
    func _numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 0
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return _numberOfSectionsInCollectionView(collectionView)
    }

    func _collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _collectionView(collectionView, numberOfItemsInSection: section)
    }

    func _collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return (nil as UICollectionViewCell?)!
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return _collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }

    func _collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return (nil as UICollectionReusableView?)!
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return _collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
}

public class RxCollectionViewSectionedDataSource<S: SectionModelType> : _RxCollectionViewSectionedDataSource {
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (UICollectionView, NSIndexPath, I) -> UICollectionViewCell
    public typealias SupplementaryViewFactory = (UICollectionView, String, NSIndexPath) -> UICollectionReusableView
    
    public typealias IncrementalUpdateObserver = AnyObserver<Changeset<S>>
    
    public typealias IncrementalUpdateDisposeKey = Bag<IncrementalUpdateObserver>.KeyType
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    var sectionModels: [SectionModelSnapshot] = []
    
    public func sectionAtIndex(section: Int) -> S {
        return self.sectionModels[section].model
    }

    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self.sectionModels[indexPath.section].items[indexPath.item]
    }
    
    var incrementalUpdateObservers: Bag<IncrementalUpdateObserver> = Bag()
    
    public func setSections(sections: [S]) {
        self.sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var cellFactory: CellFactory! = nil
    public var supplementaryViewFactory: SupplementaryViewFactory
    
    public override init() {
        self.cellFactory = { _, _, _ in return (nil as UICollectionViewCell?)! }
        self.supplementaryViewFactory = { _, _, _ in (nil as UICollectionReusableView?)! }
        
        super.init()
        
        self.cellFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `cellFactory` property on \(self!) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            
            return (nil as UICollectionViewCell!)!
        }
        
        self.supplementaryViewFactory = { [weak self] _, _, _ in
            precondition(false, "There is a minor problem. `supplementaryViewFactory` property on \(self!) was not set.")
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // observers
    
    public func addIncrementalUpdatesObserver(observer: IncrementalUpdateObserver) -> IncrementalUpdateDisposeKey {
        return incrementalUpdateObservers.insert(observer)
    }
    
    public func removeIncrementalUpdatesObserver(key: IncrementalUpdateDisposeKey) {
        let element = incrementalUpdateObservers.removeKey(key)
        precondition(element != nil, "Element removal failed")
    }
    
    // UITableViewDataSource
    
    override func _numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionModels.count
    }
    
    override func _collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionModels[section].items.count
    }
    
    override func _collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < sectionModels[indexPath.section].items.count)
        
        return cellFactory(collectionView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(collectionView, kind, indexPath)
    }
}