//
//  CollectionViewSectionedDataSource.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxCocoa
#endif
    
public class _CollectionViewSectionedDataSource
    : NSObject
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
    
    func _collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }
    
    public func collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return _collectionView(collectionView, canMoveItemAtIndexPath: indexPath)
    }
    
    func _collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
    }
    public func collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        _collectionView(collectionView, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
    
}

public class CollectionViewSectionedDataSource<S: SectionModelType>
    : _CollectionViewSectionedDataSource
    , SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, NSIndexPath, I) -> UICollectionViewCell
    public typealias SupplementaryViewFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, String, NSIndexPath) -> UICollectionReusableView
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    public func sectionAtIndex(section: Int) -> S {
        return self._sectionModels[section].model
    }
    
    public func itemAtIndexPath(indexPath: NSIndexPath) -> I {
        return self._sectionModels[indexPath.section].items[indexPath.item]
    }
    
    public func modelAtIndexPath(indexPath: NSIndexPath) throws -> Any {
        return itemAtIndexPath(indexPath)
    }
    
    public func setSections(sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var cellFactory: CellFactory! = nil
    public var supplementaryViewFactory: SupplementaryViewFactory
    
    public var moveItem: ((CollectionViewSectionedDataSource<S>, sourceIndexPath:NSIndexPath, destinationIndexPath:NSIndexPath) -> Void)?
    public var canMoveItemAtIndexPath: ((CollectionViewSectionedDataSource<S>, indexPath:NSIndexPath) -> Bool)?
    
    public override init() {
        self.cellFactory = {_, _, _, _ in return (nil as UICollectionViewCell?)! }
        self.supplementaryViewFactory = {_, _, _, _ in (nil as UICollectionReusableView?)! }
        
        super.init()
        
        self.cellFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `cellFactory` property on \(self!) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            
            return (nil as UICollectionViewCell!)!
        }
        
        self.supplementaryViewFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `supplementaryViewFactory` property on \(self!) was not set.")
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // UICollectionViewDataSource
    
    override func _numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return _sectionModels.count
    }
    
    override func _collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    override func _collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return cellFactory(self, collectionView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(self, collectionView, kind, indexPath)
    }
    
    override func _collectionView(collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath: indexPath) else {
            return super._collectionView(collectionView, canMoveItemAtIndexPath: indexPath)
        }
        
        return canMoveItem
    }
    
    override func _collectionView(collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        guard let _ = moveItem?(self, sourceIndexPath:sourceIndexPath, destinationIndexPath: destinationIndexPath) else {
            super._collectionView(collectionView, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
            return
        }
    }
    
}