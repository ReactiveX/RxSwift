//
//  RxCollectionViewSectionedDataSource.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

public class RxCollectionViewSectionedDataSource<S: SectionModelType> : RxCollectionViewNopDataSource, RxCollectionViewDataSourceType {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (UICollectionView, NSIndexPath, Section, I) -> UICollectionViewCell
    public typealias SupplementaryViewFactory = (UICollectionView, String, NSIndexPath, I) -> UICollectionReusableView
    
    public typealias IncrementalUpdateObserver = ObserverOf<Changeset<S>>
    
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
    
    var incrementalUpdateObservers: Bag<IncrementalUpdateObserver> = Bag()
    
    public func setSections(sections: [S]) {
        self.sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var cellFactory: CellFactory! = nil
    public var supplementaryViewFactory: SupplementaryViewFactory
    
    public override init() {
        self.cellFactory = { _, _, _, _ in castOrFail(nil).get() }
        self.supplementaryViewFactory = { _, _, _, _ in castOrFail(nil).get() }
        
        super.init()
        self.cellFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `cellFactory` property on \(self!) was not set. Please set it manually, or use one of the `rx_subscribeTo` methods.")
            
            return (nil as UICollectionViewCell!)!
        }
        
        self.supplementaryViewFactory = { [weak self] _, _, _, _ in
            precondition(false, "There is a minor problem. `supplementaryViewFactory` property on \(self!) was not set.")
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // observers
    
    public func addIncrementalUpdatesObserver(observer: IncrementalUpdateObserver) -> IncrementalUpdateDisposeKey {
        return incrementalUpdateObservers.put(observer)
    }
    
    public func removeIncrementalUpdatesObserver(key: IncrementalUpdateDisposeKey) {
        let element = incrementalUpdateObservers.removeKey(key)
        precondition(element != nil, "Element removal failed")
    }
    
    // UITableViewDataSource
    
    public override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return sectionModels.count
    }
    
    public override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionModels[section].items.count
    }
    
    public override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < sectionModels[indexPath.section].items.count)
        
        let item = indexPath.item
        let section = sectionModels[indexPath.section]
        return cellFactory(collectionView, indexPath, section.model, section.items[item])
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(collectionView, kind, indexPath, sectionModels[indexPath.section].items[indexPath.item])
    }
}