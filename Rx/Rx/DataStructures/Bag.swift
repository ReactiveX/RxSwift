//
//  Bag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

private struct BagPrivate {
    static let maxElements = Bag<Void>.KeyType.max - 1 // this is guarding from theoretical endless loop
}

public struct Bag<Element> {
    public typealias KeyType = Int
    
    private var map: [KeyType: Element] = Dictionary(minimumCapacity: 5)
    private var nextKey = KeyType.min

    public init() {
    }
    
    public var count: Int {
        get {
            return map.count
        }
    }
    
    public mutating func put(x: Element) -> KeyType {
        if map.count >= BagPrivate.maxElements {
            rxFatalError("Too many elements")
        }
        
        while map[nextKey] != nil {
            nextKey++
        }

        map[nextKey] = x
        
        return nextKey
    }
    
    public var all: [Element]
    {
        get {
            return self.map.values.array
        }
    }
    
    public mutating func removeAll() {
        map.removeAll(keepCapacity: false)
    }
    
    public mutating func removeKey(key: KeyType) -> Element? {
        return map.removeValueForKey(key)
    }

}