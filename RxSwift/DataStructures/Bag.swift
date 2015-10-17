//
//  Bag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Class that enables using memory allocations as a means to uniquely identify objects.
*/
class Identity {
    // weird things have known to happen with Swift
    var _forceAllocation: Int32 = 0
}

/**
Unique identifier for object added to `Bag`.
*/
public struct BagKey : Equatable {
    let uniqueIdentity: Identity?
    let key: Int
}

/**
Compares two `BagKey`s.
*/
public func == (lhs: BagKey, rhs: BagKey) -> Bool {
    return lhs.key == rhs.key && lhs.uniqueIdentity === rhs.uniqueIdentity
}

/**
Data structure that represents a bag of elements typed `T`.

Single element can be stored multiple times.

Time and space complexity of insertion an deletion is O(n). 

It is suitable for storing small number of elements.
*/
public struct Bag<T> : CustomStringConvertible {
    /**
    Type of identifier for inserted elements.
    */
    public typealias KeyType = BagKey
    
    private typealias ScopeUniqueTokenType = Int
    
    typealias Entry = (key: BagKey, value: T)
 
    private var uniqueIdentity: Identity?
    private var nextKey: ScopeUniqueTokenType = 0
    
    var pairs = [Entry]()

    /**
    Creates new empty `Bag`.
    */
    public init() {
    }
    
    /**
    - returns: Bag description.
    */
    public var description : String {
        get {
            return "\(self.count) elements in Bag"
        }
    }
    
    /**
    Inserts `value` into bag.
    
    - parameter element: Element to insert.
    - returns: Key that can be used to remove element from bag.
    */
    public mutating func insert(element: T) -> BagKey {
        nextKey = nextKey &+ 1

#if DEBUG
        nextKey = nextKey % 20
#endif
        
        if nextKey == 0 {
            uniqueIdentity = Identity()
        }
        
        let key = BagKey(uniqueIdentity: uniqueIdentity, key: nextKey)
        
        pairs.append(key: key, value: element)
        
        return key
    }
    
    /**
    - returns: Number of elements in bag.
    */
    public var count: Int {
        return pairs.count
    }
    
    /**
    Removes all elements from bag and clears capacity.
    */
    public mutating func removeAll() {
        pairs.removeAll(keepCapacity: false)
    }
    
    /**
    Removes element with a specific `key` from bag.
    
    - parameter key: Key that identifies element to remove from bag.
    - returns: Element that bag contained, or nil in case element was already removed.
    */
    public mutating func removeKey(key: BagKey) -> T? {
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
    /**
    Enumerates elements inside the bag.
    
    - parameter action: Enumeration closure.
    */
    public func forEach(@noescape action: (T) -> Void) {
        let pairs = self.pairs
        
        for i in 0 ..< pairs.count {
            action(pairs[i].value)
        }
    }
}