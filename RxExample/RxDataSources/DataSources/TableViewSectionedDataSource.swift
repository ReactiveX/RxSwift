//
//  TableViewSectionedDataSource.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
#if !RX_NO_MODULE
import RxCocoa
#endif

// objc monkey business
open class _TableViewSectionedDataSource
    : NSObject
    , UITableViewDataSource {
    
    open func _rx_numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return _rx_numberOfSections(in: tableView)
    }

    open func _rx_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _rx_tableView(tableView, numberOfRowsInSection: section)
    }

    open func _rx_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return (nil as UITableViewCell?)!
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return _rx_tableView(tableView, cellForRowAt: indexPath)
    }

    open func _rx_tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _rx_tableView(tableView, titleForHeaderInSection: section)
    }

    open func _rx_tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _rx_tableView(tableView, titleForFooterInSection: section)
    }
    
    open func _rx_tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return _rx_tableView(tableView, canEditRowAt: indexPath)
    }
    
    open func _rx_tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return _rx_tableView(tableView, canMoveRowAt: indexPath)
    }

    #if os(iOS)
    open func _rx_sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return nil
    }
    
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return _rx_sectionIndexTitles(for: tableView)
    }

    open func _rx_tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return 0
    }

    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return _rx_tableView(tableView, sectionForSectionIndexTitle: title, at: index)
    }
    #endif

    open func _rx_tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _rx_tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
    }

}

open class TableViewSectionedDataSource<S: SectionModelType>
    : _TableViewSectionedDataSource
    , SectionedViewDataSourceType {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (TableViewSectionedDataSource<S>, UITableView, IndexPath, I) -> UITableViewCell

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
    
    open var titleForHeaderInSection: ((TableViewSectionedDataSource<S>, Int) -> String?)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var titleForFooterInSection: ((TableViewSectionedDataSource<S>, Int) -> String?)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var canEditRowAtIndexPath: ((TableViewSectionedDataSource<S>, IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var canMoveRowAtIndexPath: ((TableViewSectionedDataSource<S>, IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var rowAnimation: UITableViewRowAnimation = .automatic

    #if os(iOS)
    open var sectionIndexTitles: ((TableViewSectionedDataSource<S>) -> [String]?)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var sectionForSectionIndexTitle:((TableViewSectionedDataSource<S>, _ title: String, _ index: Int) -> Int)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    #endif
    
    public override init() {
        super.init()
        self.configureCell = { [weak self] _ in
            if let strongSelf = self {
                precondition(false, "There is a minor problem. `cellFactory` property on \(strongSelf) was not set. Please set it manually, or use one of the `rx_bindTo` methods.")
            }
            
            return (nil as UITableViewCell!)!
        }
    }
    
    // UITableViewDataSource
    
    open override func _rx_numberOfSections(in tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    open override func _rx_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    open override func _rx_tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, tableView, indexPath, self[indexPath])
    }
    
    open override func _rx_tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(self, section)
    }
    
    open override func _rx_tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(self, section)
    }
    
    open override func _rx_tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        guard let canEditRow = canEditRowAtIndexPath?(self, indexPath) else {
            return super._rx_tableView(tableView, canEditRowAt: indexPath)
        }
        
        return canEditRow
    }
   
    open override func _rx_tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        guard let canMoveRow = canMoveRowAtIndexPath?(self, indexPath) else {
            return super._rx_tableView(tableView, canMoveRowAt: indexPath)
        }
        
        return canMoveRow
    }

    open override func _rx_tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }

    #if os(iOS)
    open override func _rx_sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard let titles = sectionIndexTitles?(self) else {
            return super._rx_sectionIndexTitles(for: tableView)
        }
        
        return titles
    }
    
    open override func _rx_tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        guard let section = sectionForSectionIndexTitle?(self, title, index) else {
            return super._rx_tableView(tableView, sectionForSectionIndexTitle: title, at: index)
        }
        
        return section
    }
    #endif
}
