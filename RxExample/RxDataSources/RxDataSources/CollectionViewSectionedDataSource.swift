//
//  CollectionViewSectionedDataSource.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 7/2/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit
#if !RX_NO_MODULE
import RxCocoa
#endif

open class CollectionViewSectionedDataSource<S: SectionModelType>
    : NSObject
    , UICollectionViewDataSource
    , SectionedViewDataSourceType {
    public typealias I = S.Item
    public typealias Section = S
    public typealias ConfigureCell = (CollectionViewSectionedDataSource<S>, UICollectionView, IndexPath, I) -> UICollectionViewCell
    public typealias ConfigureSupplementaryView = (CollectionViewSectionedDataSource<S>, UICollectionView, String, IndexPath) -> UICollectionReusableView
    public typealias MoveItem = (CollectionViewSectionedDataSource<S>, _ sourceIndexPath:IndexPath, _ destinationIndexPath:IndexPath) -> Void
    public typealias CanMoveItemAtIndexPath = (CollectionViewSectionedDataSource<S>, IndexPath) -> Bool


    public init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: @escaping ConfigureSupplementaryView,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
    ) {
        self.configureCell = configureCell
        self.configureSupplementaryView = configureSupplementaryView
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

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
    
    open var configureCell: ConfigureCell {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var configureSupplementaryView: ConfigureSupplementaryView {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var moveItem: MoveItem {
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

    // UICollectionViewDataSource
    
    open func numberOfSections(in collectionView: UICollectionView) -> Int {
        return _sectionModels.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, collectionView, indexPath, self[indexPath])
    }
    
    open func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return configureSupplementaryView(self, collectionView, kind, indexPath)
    }
    
    open func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        guard let canMoveItem = canMoveItemAtIndexPath?(self, indexPath) else {
            return false
        }
        
        return canMoveItem
    }
    
    open func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem(self, sourceIndexPath, destinationIndexPath)
    }
    
}
#endif
