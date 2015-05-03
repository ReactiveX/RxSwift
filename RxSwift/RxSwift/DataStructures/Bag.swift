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

public struct Bag<T> : SequenceType, Printable {
    typealias Generator = GeneratorOf<T>
    
    public typealias KeyType = Int
    
    private var map: [KeyType: T] = Dictionary(minimumCapacity: 5)
    private var nextKey: KeyType = 0

    public init() {
    }
    
    public var description : String {
        get {
            return "\(map.count) elements \(self.map)"
        }
    }
    
    public var count: Int {
        get {
            return map.count
        }
    }
    
    public mutating func put(x: T) -> KeyType {
        if map.count >= BagPrivate.maxElements {
            rxFatalError("Too many elements")
        }
        
        while map[nextKey] != nil {
            nextKey = nextKey &+ 1
        }

        map[nextKey] = x
        
        return nextKey
    }
    
    public func generate() -> GeneratorOf<T> {
        var dictionaryGenerator = map.generate()
        
        return GeneratorOf {
            let next = dictionaryGenerator.next()
            if let (key, value) = next {
                return value
            }
            else {
                return nil
            }
        }
    }
    
    public var all: [T]
    {
        get {
            return self.map.values.array
        }
    }
    
    public mutating func removeAll() {
        map.removeAll(keepCapacity: false)
    }
    
    public mutating func removeKey(key: KeyType) -> T? {
        return map.removeValueForKey(key)
    }

}