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
    
    func _numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return 0
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _numberOfSectionsInCollectionView(collectionView)
    }

    func _rx_collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _rx_collectionView(collectionView, numberOfItemsInSection: section)
    }

    func _rx_collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        return (nil as UICollectionViewCell?)!
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return _rx_collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }

    func _rx_collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        return (nil as UICollectionReusableView?)!
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return _rx_collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    
    func _rx_collectionView(_ collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return _rx_collectionView(collectionView, canMoveItemAtIndexPath: indexPath)
    }
    
    func _rx_collectionView(_ collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        
    }
    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _rx_collectionView(collectionView, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
    
}

public class CollectionViewSectionedDataSource<S: SectionModelType>
    : _CollectionViewSectionedDataSource
    , SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, IndexPath, I) -> UICollectionViewCell
    public typealias SupplementaryViewFactory = (CollectionViewSectionedDataSource<S>, UICollectionView, String, NSIndexPath) -> UICollectionReusableView

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

    public var sectionModels: [S] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }

    public func sectionAtIndex(_ section: Int) -> S {
        let sectionModel = self._sectionModels[section]
        return S(original: sectionModel.model, items: sectionModel.items)
    }
    
    public func itemAtIndexPath(_ indexPath: IndexPath) -> I {
        return self._sectionModels[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).item]
    }
    
    public func modelAtIndexPath(_ indexPath: IndexPath) throws -> Any {
        return itemAtIndexPath(indexPath)
    }
    
    public func setSections(_ sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    public var configureCell: CellFactory! = nil {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    @available(*, deprecated:0.8.1, renamed:"configureCell")
    public var cellFactory: CellFactory! {
        get {
            return self.configureCell
        }
        set {
            self.configureCell = newValue
        }
    }

    public var supplementaryViewFactory: SupplementaryViewFactory {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    public var moveItem: ((CollectionViewSectionedDataSource<S>, sourceIndexPath:IndexPath, destinationIndexPath:IndexPath) -> Void)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    public var canMoveItemAtIndexPath: ((CollectionViewSectionedDataSource<S>, indexPath:IndexPath) -> Bool)? {
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
    
    override func _numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int {
        return _sectionModels.count
    }
    
    override func _rx_collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    override func _rx_collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell {
        precondition((indexPath as NSIndexPath).item < _sectionModels[(indexPath as NSIndexPath).section].items.count)
        
        return configureCell(self, collectionView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _rx_collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: IndexPath) -> UICollectionReusableView {
        return supplementaryViewFactory(self, collectionView, kind, indexPath)
    }
    
    override func _rx_collectionView(_ collectionView: UICollectionView, canMoveItemAtIndexPath indexPath: IndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath: indexPath) else {
            return super._rx_collectionView(collectionView, canMoveItemAtIndexPath: indexPath)
        }
        
        return canMoveItem
    }
    
    override func _rx_collectionView(_ collectionView: UICollectionView, moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
}
