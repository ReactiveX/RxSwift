//
//  SectionModel.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 6/16/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct SectionModel<Section, ItemType> : SectionModelType, CustomStringConvertible {
    public typealias Item = ItemType
    public var model: Section
    
    public var items: [Item]
    
    public init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
    
    public init(original: SectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
    public var description: String {
        get {
            return "\(self.model) > \(items)"
        }
    }
}

public struct HashableSectionModel<Section: Hashable, ItemType: Hashable> : Hashable, SectionModelType, CustomStringConvertible {
    public typealias Item = ItemType
    public var model: Section
    
    public var items: [Item]
    
    public init(model: Section, items: [Item]) {
        self.model = model
        self.items = items
    }
    
    public init(original: HashableSectionModel, items: [Item]) {
        self.model = original.model
        self.items = items
    }
    
    public var description: String {
        get {
            return "HashableSectionModel(model: \"\(self.model)\", items: \(items))"
        }
    }
    
    public var hashValue: Int {
        get {
            return self.model.hashValue
        }
    }

}

public func == <S, I>(lhs: HashableSectionModel<S, I>, rhs: HashableSectionModel<S, I>) -> Bool {
    return lhs.model == rhs.model
}