//
//  SectionModel.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 6/16/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct SectionModel<Section, ItemType>
    : SectionModelType
    , CustomStringConvertible {
    public typealias Identity = Section
    public typealias Item = ItemType
    public var model: Section

    public var identity: Section {
        return model
    }

    public var items: [Item]
    
    public init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }

    public var description: String {
        return "\(self.model) > \(items)"
    }
}

