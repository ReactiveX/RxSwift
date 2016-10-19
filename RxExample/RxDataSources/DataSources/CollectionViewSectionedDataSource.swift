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
    
open class _CollectionViewSectionedDataSource
    : NSObject
    , UICollectionViewDataSource {
    
    open func _rx_numberOfSections(in collectionView: UICollectionView) -> Int {
        return 0
    }
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _rx_numberOfSections(in: collectionView)
    }

    open func _rx_collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _rx_collectionView(collectionView, numberOfItemsInSection: section)
    }

    open func _rx_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return (nil as UICollectionViewCell?)!
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return _rx_collectionView(collectionView, cellForItemAt: indexPath)
    }

    open func _rx_collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        return (nil as UICollectionReusableView?)!
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return _rx_collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    open func _rx_collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return _rx_collectionView(collectionView, canMoveItemAt: indexPath)
    }
    
    open func _rx_collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
    }
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _rx_collectionView(collectionView, moveItemAt: sourceIndexPath, to: destinationIndexPath)
    }
    
}

open class CollectionViewSectionedDataSource<S: SectionModelType>
    : _CollectionViewSectionedDataSource
    , SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, IndexPath, I) -> UICollectionViewCell
    public typealias SupplementaryViewFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, String, IndexPath) -> UICollectionReusableView

    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false

    private func ensureNotMutatedAfterBinding() {
        assert(!_dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }
    
    #endif

    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []

    open var sectionModels: [S] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }

    open subscript(section: Int) -> S {
        let sectionModel = self._sectionModels[section]
        return S(original: sectionModel.model, items: sectionModel.items)
    }
    
    open subscript(indexPath: IndexPath) -> I {
        get {
            return self._sectionModels[indexPath.section].items[indexPath.item]
        }
        set(item) {
            var section = self._sectionModels[indexPath.section]
            section.items[indexPath.item] = item
            self._sectionModels[indexPath.section] = section
        }
    }
    
    open func model(at indexPath: IndexPath) throws -> Any {
        return self[indexPath]
    }
    
    open func setSections(_ sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    open var configureCell: CellFactory! = nil {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var supplementaryViewFactory: SupplementaryViewFactory {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var moveItem: ((CollectionViewSectionedDataSource<S>, _ sourceIndexPath:IndexPath, _ destinationIndexPath:IndexPath) -> Void)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var canMoveItemAtIndexPath: ((CollectionViewSectionedDataSource<S>, IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    public override init() {
        self.configureCell = {_, _, _, _ in return (nil as UICollectionViewCell?)! }
        self.supplementaryViewFactory = {_, _, _, _ in (nil as UICollectionReusableView?)! }
        
        super.init()
        
        self.configureCell = { [weak self] _ in
            precondition(false, "There is a minor problem. `cellFactory` property on \(self!) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            
            return (nil as UICollectionViewCell!)!
        }
        
        self.supplementaryViewFactory = { [weak self] _ in
            precondition(false, "There is a minor problem. `supplementaryViewFactory` property on \(self!) was not set.")
            return (nil as UICollectionReusableView?)!
        }
    }
    
    // UICollectionViewDataSource
    
    open override func _rx_numberOfSections(in collectionView: UICollectionView) -> Int {
        return _sectionModels.count
    }
    
    open override func _rx_collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    open override func _rx_collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, collectionView, indexPath, self[indexPath])
    }
    
    open override func _rx_collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(self, collectionView, kind, indexPath)
    }
    
    open override func _rx_collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath) else {
            return super._rx_collectionView(collectionView, canMoveItemAt: indexPath)
        }
        
        return canMoveItem
    }
    
    open override func _rx_collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem?(self, sourceIndexPath, destinationIndexPath)
    }
    
}
