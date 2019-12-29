//
//  TableViewSectionedDataSource.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(iOS) || os(tvOS)

import Foundation
import UIKit
import RxCocoa

open class TableViewSectionedDataSource<Section: SectionModelType>
    : NSObject
    , UITableViewDataSource
    , SectionedViewDataSourceType {
    
    public typealias Item = Section.Item

    public typealias ConfigureCell = (TableViewSectionedDataSource<Section>, UITableView, IndexPath, Item) -> UITableViewCell
    public typealias TitleForHeaderInSection = (TableViewSectionedDataSource<Section>, Int) -> String?
    public typealias TitleForFooterInSection = (TableViewSectionedDataSource<Section>, Int) -> String?
    public typealias CanEditRowAtIndexPath = (TableViewSectionedDataSource<Section>, IndexPath) -> Bool
    public typealias CanMoveRowAtIndexPath = (TableViewSectionedDataSource<Section>, IndexPath) -> Bool

    #if os(iOS)
        public typealias SectionIndexTitles = (TableViewSectionedDataSource<Section>) -> [String]?
        public typealias SectionForSectionIndexTitle = (TableViewSectionedDataSource<Section>, _ title: String, _ index: Int) -> Int
    #endif

    #if os(iOS)
        public init(
                configureCell: @escaping ConfigureCell,
                titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
                titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
                canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
                canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
                sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
                sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
            ) {
            self.configureCell = configureCell
            self.titleForHeaderInSection = titleForHeaderInSection
            self.titleForFooterInSection = titleForFooterInSection
            self.canEditRowAtIndexPath = canEditRowAtIndexPath
            self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
            self.sectionIndexTitles = sectionIndexTitles
            self.sectionForSectionIndexTitle = sectionForSectionIndexTitle
        }
    #else
        public init(
                configureCell: @escaping ConfigureCell,
                titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
                titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
                canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
                canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
            ) {
            self.configureCell = configureCell
            self.titleForHeaderInSection = titleForHeaderInSection
            self.titleForFooterInSection = titleForFooterInSection
            self.canEditRowAtIndexPath = canEditRowAtIndexPath
            self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
        }
    #endif

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
    public typealias SectionModelSnapshot = SectionModel<Section, Item>
    
    private var _sectionModels: [SectionModelSnapshot] = []

    open var sectionModels: [Section] {
        _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }

    open subscript(section: Int) -> Section {
        let sectionModel = self._sectionModels[section]
        return Section(original: sectionModel.model, items: sectionModel.items)
    }

    open subscript(indexPath: IndexPath) -> Item {
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
        self[indexPath]
    }

    open func setSections(_ sections: [Section]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }

    open var configureCell: ConfigureCell {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var titleForHeaderInSection: TitleForHeaderInSection {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var titleForFooterInSection: TitleForFooterInSection {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var canEditRowAtIndexPath: CanEditRowAtIndexPath {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var canMoveRowAtIndexPath: CanMoveRowAtIndexPath {
        didSet {
            #if DEBUG
                ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var rowAnimation: UITableView.RowAnimation = .automatic

    #if os(iOS)
    open var sectionIndexTitles: SectionIndexTitles {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    open var sectionForSectionIndexTitle: SectionForSectionIndexTitle {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    #endif
    

    // UITableViewDataSource
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        _sectionModels.count
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard _sectionModels.count > section else { return 0 }
        return _sectionModels[section].items.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)
        
        return configureCell(self, tableView, indexPath, self[indexPath])
    }
    
    open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titleForHeaderInSection(self, section)
    }
   
    open func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        titleForFooterInSection(self, section)
    }
    
    open func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRowAtIndexPath(self, indexPath)
    }
   
    open func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        canMoveRowAtIndexPath(self, indexPath)
    }

    open func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }

    #if os(iOS)
    open func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        sectionIndexTitles(self)
    }
    
    open func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        sectionForSectionIndexTitle(self, title, index)
    }
    #endif
}
#endif
