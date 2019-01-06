//
//  Bag.swift
//  Platform
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Swift

let arrayDictionaryMaxSize = 30

struct BagKey {
    /**
    Unique identifier for object added to `Bag`.
     
    It's underlying type is UInt64. If we assume there in an idealized CPU that works at 4GHz,
     it would take ~150 years of continuous running time for it to overflow.
    */
    fileprivate let rawValue: UInt64
}

/**
Data structure that represents a bag of elements typed `T`.

Single element can be stored multiple times.

Time and space complexity of insertion and deletion is O(n). 

It is suitable for storing small number of elements.
*/
struct Bag<T>: CustomDebugStringConvertible {
    /// Type of identifier for inserted elements.
    typealias KeyType = BagKey
    
    typealias Entry = (key: BagKey, value: T)
 
    fileprivate var _nextKey: BagKey = BagKey(rawValue: 0)

    // data

    // first fill inline variables
    var _key0: BagKey?
    var _value0: T?

    // then fill "array dictionary"
    var _pairs = ContiguousArray<Entry>()

    // last is sparse dictionary
    var _dictionary: [BagKey: T]?

    var _onlyFastPath = true

    /// Creates new empty `Bag`.
    init() {
    }
    
    /**
    Inserts `value` into bag.
    
    - parameter element: Element to insert.
    - returns: Key that can be used to remove element from bag.
    */
    mutating func insert(_ element: T) -> BagKey {
        let key = self._nextKey

        self._nextKey = BagKey(rawValue: self._nextKey.rawValue &+ 1)

        if self._key0 == nil {
            self._key0 = key
            self._value0 = element
            return key
        }

        self._onlyFastPath = false

        if self._dictionary != nil {
            self._dictionary![key] = element
            return key
        }

        if self._pairs.count < arrayDictionaryMaxSize {
            self._pairs.append((key: key, value: element))
            return key
        }
        
        self._dictionary = [key: element]
        
        return key
    }
    
    /// - returns: Number of elements in bag.
    var count: Int {
        let dictionaryCount: Int = self._dictionary?.count ?? 0
        return (self._value0 != nil ? 1 : 0) + self._pairs.count + dictionaryCount
    }
    
    /// Removes all elements from bag and clears capacity.
    mutating func removeAll() {
        self._key0 = nil
        self._value0 = nil

        self._pairs.removeAll(keepingCapacity: false)
        self._dictionary?.removeAll(keepingCapacity: false)
    }
    
    /**
    Removes element with a specific `key` from bag.
    
    - parameter key: Key that identifies element to remove from bag.
    - returns: Element that bag contained, or nil in case element was already removed.
    */
    mutating func removeKey(_ key: BagKey) -> T? {
        if self._key0 == key {
            self._key0 = nil
            let value = self._value0!
            self._value0 = nil
            return value
        }

        if let existingObject = self._dictionary?.removeValue(forKey: key) {
            return existingObject
        }

        for i in 0 ..< self._pairs.count where self._pairs[i].key == key {
            let value = self._pairs[i].value
            self._pairs.remove(at: i)
            return value
        }

        return nil
    }
}

extension Bag {
    /// A textual representation of `self`, suitable for debugging.
    var debugDescription: String {
        return "\(self.count) elements in Bag"
    }
}

extension Bag {
    /// Enumerates elements inside the bag.
    ///
    /// - parameter action: Enumeration closure.
    func forEach(_ action: (T) -> Void) {
        if self._onlyFastPath {
            if let value0 = self._value0 {
                action(value0)
            }
            return
        }

        let value0 = self._value0
        let dictionary = self._dictionary

        if let value0 = value0 {
            action(value0)
        }

        for i in 0 ..< self._pairs.count {
            action(self._pairs[i].value)
        }

        if dictionary?.count ?? 0 > 0 {
            for element in dictionary!.values {
                action(element)
            }
        }
    }
}

extension BagKey: Hashable {
    var hashValue: Int {
        return self.rawValue.hashValue
    }
}

func ==(lhs: BagKey, rhs: BagKey) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
