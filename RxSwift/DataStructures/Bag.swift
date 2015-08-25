//
//  Bag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Identity {
    // weird things have known to happen with Swift
    var _forceAllocation: Int32 = 0
}

public struct BagKey : Equatable {
    let uniqueIdentity: Identity?
    let key: Int
}

public func == (lhs: BagKey, rhs: BagKey) -> Bool {
    return lhs.key == rhs.key && lhs.uniqueIdentity === rhs.uniqueIdentity
}

public struct Bag<T> : CustomStringConvertible {
    public typealias KeyType = BagKey
    private typealias ScopeUniqueTokenType = Int
    
    typealias Entry = (key: BagKey, value: T)
 
    private var uniqueIdentity: Identity?
    private var nextKey: ScopeUniqueTokenType = 0
    
    var preallocated_0: Entry?
    var preallocated_1: Entry?
    
    var pairs = [Entry]()

    public init() {
    }
    
    public var description : String {
        get {
            return "\(self.count) elements in Bag"
        }
    }
    
    public mutating func put(value: T) -> BagKey {
        nextKey = nextKey &+ 1

#if DEBUG
        nextKey = nextKey % 20
#endif
        
        if nextKey == 0 {
            uniqueIdentity = Identity()
        }
        
        let key = BagKey(uniqueIdentity: uniqueIdentity, key: nextKey)
        
        if preallocated_0 == nil {
            preallocated_0 = (key: key, value: value)
            return key
        }
        
        if preallocated_1 == nil {
            preallocated_1 = (key: key, value: value)
            return key
        }
        
        pairs.append(key: key, value: value)
        
        return key
    }
    
    public var count: Int {
        return pairs.count + (preallocated_0 != nil ? 1 : 0) + (preallocated_1 != nil ? 1 : 0)
    }
    
    public mutating func removeAll() {
        preallocated_0 = nil
        preallocated_1 = nil
        pairs.removeAll(keepCapacity: false)
    }
    
    public mutating func removeKey(key: BagKey) -> T? {
        if preallocated_0?.key == key {
            let value = preallocated_0!.value
            preallocated_0 = nil
            return value
        }
        if preallocated_1?.key == key {
            let value = preallocated_1!.value
            preallocated_1 = nil
            return value
        }
        
        for i in 0 ..< pairs.count {
            if pairs[i].key == key {
                let value = pairs[i].value
                pairs.removeAtIndex(i)
                return value
            }
        }
    
        return nil
    }
}

extension Bag {
    public func forEach(@noescape action: (T) -> Void) {
        let value0 = preallocated_0
        let value1 = preallocated_1
        
        let pairs = self.pairs
        
        if let value = value0?.value {
            action(value)
        }
        
        if let value = value1?.value {
            action(value)
        }
        
        for i in 0 ..< pairs.count {
            action(pairs[i].value)
        }
    }
}