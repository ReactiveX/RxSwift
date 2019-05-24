//
//  BehaviorRelay+Append.swift
//
//  Created by Cristiano Maria Coppotelli on 15/05/2019.
//  Copyright © 2019 Cristiano Maria Coppotelli. All rights reserved.
//

public extension BehaviorRelay where Element : Collection {
    
    /// Removes an element from the observable sequence, accepting the updated value.
    ///
    /// - Parameter at: The integer index where the value to remove resides.
    final func acceptRemoving<Value>(at index: Int) where Element == Array<Value> {
        var newValue = self.value
        newValue.remove(at: index)
        self.accept(newValue)
    }
    
    /// Removes elements from the obeservable sequence at the given indexes, accepting the updated
    /// value.
    ///
    /// - Parameter at: Integer indexes where the values to remove reside.
    ///
    /// - Complexity: O(n) where n is the length of the given indexes array.
    final func acceptRemoving<Value>(at indexes: [Int]) where Element == Array<Value> {
        var newValue = self.value
        indexes.forEach { newValue.remove(at: $0) }
        self.accept(newValue)
    }
    
    /// Removes elements from the observable sequence satisfying the given predicate, accepting the
    /// updated value.
    ///
    /// - Parameter where: The predicate to test values against.
    final func acceptRemoving<Value>(where predicate: @escaping((Value) throws -> Bool)) where Element == Array<Value> {
        var newValue = self.value
        try? newValue.removeAll(where: predicate)
        self.accept(newValue)
    }
    
    /// Appends an element to the observable sequence, accepting the updated value.
    ///
    /// - Parameter element: The value to append.
    final func acceptAppending<Value>(_ element: Value) where Element == Array<Value> {
        var newValue = self.value
        newValue.append(element)
        self.accept(newValue)
    }
    
    /// Appends elements to the observable sequence, accepting the updated value.
    ///
    /// - Parameter contentsOf: An array of elements from which elements are appended to the
    ///                         observable sequence.
    final func acceptAppending<Value>(contentsOf sequence: [Value]) where Element == Array<Value> {
        var newValue = self.value
        newValue.append(contentsOf: sequence)
        self.accept(newValue)
    }
    
    /// Updates an element at the given index of the observable sequence, accepting the updated value.
    ///
    /// - Parameter at: The integer index where the value to update resides.
    /// - Parameter with: The value to replace the old with.
    final func acceptUpdating<Value>(at index: Int, with updatedValue: Value) where Element == Array<Value> {
        var newValue = self.value
        newValue[index] = updatedValue
        self.accept(newValue)
    }
    
    /// Updates an element identified with the given key, with the new value, accepting the updated
    /// value.
    ///
    /// - Parameter value: The value to replace the old with.
    /// - Parameter forKey: The dictionary key to retrieve the value to update.
    final func acceptUpdating<Key, Value>(value: Value, forKey key: Key) where Element == Dictionary<Key, Value> {
        var newValue = self.value
        newValue[key] = value
        self.accept(newValue)
    }
    
}
