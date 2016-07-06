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
public class _TableViewSectionedDataSource
    : NSObject
    , UITableViewDataSource {
    
    func _numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return _numberOfSectionsInTableView(tableView)
    }

    func _rx_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _rx_tableView(tableView, numberOfRowsInSection: section)
    }

    func _rx_tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        return (nil as UITableViewCell?)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return _rx_tableView(tableView, cellForRowAtIndexPath: indexPath)
    }

    func _rx_tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return _rx_tableView(tableView, titleForHeaderInSection: section)
    }

    func _rx_tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return nil
    }
    
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return _rx_tableView(tableView, titleForFooterInSection: section)
    }
    
    func _rx_tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return _rx_tableView(tableView, canEditRowAtIndexPath: indexPath)
    }
    
    func _rx_tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        return false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return _rx_tableView(tableView, canMoveRowAtIndexPath: indexPath)
    }
    
    func _sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]? {
        return nil
    }
    
    public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return _sectionIndexTitlesForTableView(tableView)
    }
    
    func _rx_tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return 0
    }

    public func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return _rx_tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }

    func _rx_tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        _rx_tableView(tableView, moveRowAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }

}

public class RxTableViewSectionedDataSource<S: SectionModelType>
    : _TableViewSectionedDataSource
    , SectionedViewDataSourceType {
    
    public typealias I = S.Item
    public typealias Section = S
    public typealias CellFactory = (RxTableViewSectionedDataSource<S>, UITableView, IndexPath, I) -> UITableViewCell

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
        let sectionModel = _sectionModels[section]
        return Section(original: sectionModel.model, items: sectionModel.items)
    }

    public func itemAtIndexPath(_ indexPath: IndexPath) -> I {
        return self._sectionModels[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).item]
    }

    public func setItem(item: I, indexPath: IndexPath) {
        var section = self._sectionModels[(indexPath as NSIndexPath).section]
        section.items[(indexPath as NSIndexPath).item] = item
        self._sectionModels[(indexPath as NSIndexPath).section] = section
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
    
    public var titleForHeaderInSection: ((RxTableViewSectionedDataSource<S>, section: Int) -> String?)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    public var titleForFooterInSection: ((RxTableViewSectionedDataSource<S>, section: Int) -> String?)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    public var canEditRowAtIndexPath: ((RxTableViewSectionedDataSource<S>, indexPath: IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    public var canMoveRowAtIndexPath: ((RxTableViewSectionedDataSource<S>, indexPath: IndexPath) -> Bool)? {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    public var rowAnimation: UITableViewRowAnimation = .automatic

    public var sectionIndexTitles: ((RxTableViewSectionedDataSource<S>) -> [String]?)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    public var sectionForSectionIndexTitle:((RxTableViewSectionedDataSource<S>, title: String, index: Int) -> Int)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
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
    
    override func _numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return _sectionModels.count
    }
    
    override func _rx_tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    override func _rx_tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        precondition((indexPath as NSIndexPath).item < _sectionModels[(indexPath as NSIndexPath).section].items.count)
        
        return configureCell(self, tableView, indexPath, itemAtIndexPath(indexPath))
    }
    
    override func _rx_tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection?(self, section: section)
    }
    
    override func _rx_tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return titleForFooterInSection?(self, section: section)
    }
    
    override func _rx_tableView(_ tableView: UITableView, canEditRowAtIndexPath indexPath: IndexPath) -> Bool {
        guard let canEditRow = canEditRowAtIndexPath?(self, indexPath: indexPath) else {
            return super._rx_tableView(tableView, canEditRowAtIndexPath: indexPath)
        }
        
        return canEditRow
    }
   
    override func _rx_tableView(_ tableView: UITableView, canMoveRowAtIndexPath indexPath: IndexPath) -> Bool {
        guard let canMoveRow = canMoveRowAtIndexPath?(self, indexPath: indexPath) else {
            return super._rx_tableView(tableView, canMoveRowAtIndexPath: indexPath)
        }
        
        return canMoveRow
    }

    override func _rx_tableView(_ tableView: UITableView, moveRowAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }
    
    override func _sectionIndexTitlesForTableView(_ tableView: UITableView) -> [String]? {
        guard let titles = sectionIndexTitles?(self) else {
            return super._sectionIndexTitlesForTableView(tableView)
        }
        
        return titles
    }
    
    override func _rx_tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        guard let section = sectionForSectionIndexTitle?(self, title: title, index: index) else {
            return super._rx_tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
        }
        
        return section
    }
    
}
