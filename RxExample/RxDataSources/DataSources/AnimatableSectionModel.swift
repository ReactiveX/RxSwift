//
//  AnimatableSectionModel.swift
//  RxDataSources
//
//  Created by Krunoslav Zaher on 1/10/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct AnimatableSectionModel<Section: Hashable, ItemType: Hashable>
    : Hashable
    , AnimatableSectionModelType
    , CustomStringConvertible {
    public typealias Item = IdentifiableValue<ItemType>
    public typealias Identity = Section

    public var model: Section
    
    public var items: [Item]

    public var identity: Section {
        return model
    }
    
    public init(model: Section, items: [ItemType]) {
        self.model = model
        self.items = items.map(IdentifiableValue.init)
    }
    
    public init(original: AnimatableSectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
    public var description: String {
        return "HashableSectionModel(model: \"\(self.model)\", items: \(items))"
    }
    
    public var hashValue: Int {
        return self.model.hashValue
    }
}

public func == <S, I>(lhs: AnimatableSectionModel<S, I>, rhs: AnimatableSectionModel<S, I>) -> Bool {
    return lhs.model == rhs.model
}