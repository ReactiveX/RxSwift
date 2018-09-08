//
//  Bag.swift
//  Platform
//
//  Created by Krunoslav Zaher on 2/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Swift

struct BagKey {

    /// Unique identifier for object added to `Bag`.
    ///
    /// Its underlying type is `UInt64`. If we assume there is an idealized CPU
    /// that works at 4GHz, it would take ~150 years of continuous running time
    /// for it to overflow.
    fileprivate let rawValue: UInt64
}


/// Data structure that represents a bag of elements typed `T`.
///
/// Single element can be stored multiple times.
///
/// Space complexity of insertion and deletion is O(n). Time complexity of
/// insertion is O(1), of deletion is O(n).
///
/// It is suitable for storing small number of elements.
struct Bag<T> : CustomDebugStringConvertible {

    /// Type of identifier for inserted elements.
    typealias KeyType = BagKey
    
    typealias Entry = (key: BagKey, value: T)

    private var _nextKey = BagKey(rawValue: 0)

    // data

    // first fill inline variables
    var _key: BagKey?
    var _value: T?

    // then fill "array dictionary"
    var _pairs: ContiguousArray<Entry>?

    /// Creates new empty `Bag`.
    init() { }

    /// Inserts `element` into bag.
    ///
    /// - Parameter element: Element to insert.
    /// - Returns: Key that can be used to remove element from bag.
    mutating func insert(_ element: T) -> BagKey {
        let key = _nextKey

        _nextKey = BagKey(rawValue: _nextKey.rawValue &+ 1)

        if _key == nil {
            _key = key
            _value = element
            return key
        }

        if _pairs == nil {
            _pairs = [(key: key, value: element)]
        } else {
            _pairs!.append((key: key, value: element))
        }

        return key
    }

    /// Number of elements in bag.
    var count: Int {
        return (_value != nil ? 1 : 0) + (_pairs?.count ?? 0)
    }
    
    /// Removes all elements from bag and clears capacity.
    mutating func removeAll() {
        _key = nil
        _value = nil

        _pairs = []
    }

    /// Removes element with a specific `key` from bag.
    ///
    /// Parameter key: Key that identifies element to remove from bag.
    /// Returns: Element that bag contained, or nil in case element was already removed.
    mutating func removeKey(_ key: BagKey) -> T? {
        if key == _key {
            defer { _key = nil; _value = nil }
            return _value
        }

        if _pairs == nil { return nil }

        var left = 0, right = _pairs!.count - 1

        while left <= right {
            if _pairs![left].key == key {
                return _pairs!.remove(at: left).value
            }

            if _pairs![right].key == key {
                return _pairs!.remove(at: right).value
            }

            let mid = (left + right) / 2
            if _pairs![mid].key == key {
                return _pairs!.remove(at: mid).value
            } else if _pairs![mid].key > key {
                right = mid - 1
            } else {
                left = mid + 1
            }
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
    /// - Parameter action: Enumeration closure.
    func forEach(_ action: (T) -> Void) {
        if _value != nil { action(_value!) }

        if _pairs != nil {
            for i in _pairs!.indices {
                action(_pairs![i].value)
            }
        }
    }
}

extension BagKey: Hashable {

    var hashValue: Int {
        return rawValue.hashValue
    }

    static func == (lhs: BagKey, rhs: BagKey) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }

    fileprivate static func > (lhs: BagKey, rhs: BagKey) -> Bool {
        return lhs.rawValue > rhs.rawValue
    }
}


