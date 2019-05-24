//
//  BehaviorRelay+KeyPath.swift
//  AppUtilities
//
//  Created by Cristiano Maria Coppotelli on 24/05/2019.
//  Copyright © 2019 Cristiano Maria Coppotelli. All rights reserved.
//

public extension BehaviorRelay {
    
    /// Updates an element at the given keyPath, accepting the updated value.
    ///
    /// This generic function empowers you to update a stored property on the BehaviorRelay's value,
    /// prior to knowing how the actual Element type is made out of.
    ///
    /// This is made possible thanks to a combination of Generics and Swift KeyPaths.
    ///
    /// Example of usage, asserting Element == UIView, for changing its background color:
    ///
    ///     self.behaviorRelay.acceptUpdating(atKeyPath: \UIView.backgroundColor, with: .red)
    ///
    /// - Parameter atKeyPath: The writable key path pointing to the stored property to update.
    /// - Parameter with: The value to update the property with.
    ///
    /// - Note: This implementation is for Element's stored property being updated having reference
    ///         semantics.
    final func acceptUpdating<Value>(atKeyPath keyPath: ReferenceWritableKeyPath<Element, Value>, with updatedValue: Value) where Value: AnyObject {
        let newStream = self.value
        newStream[keyPath: keyPath] = updatedValue
        self.accept(newStream)
    }
    
    /// Updates an element at the given keyPath, accepting the updated value.
    ///
    /// This generic function empowers you to update a stored property on the BehaviorRelay's value,
    /// prior to knowing how the actual Element type is made out of.
    ///
    /// This is made possible thanks to a combination of Generics and Swift KeyPaths.
    ///
    /// Example of usage, asserting Element == UIView, for changing its background color:
    ///
    ///     self.behaviorRelay.acceptUpdating(atKeyPath: \UIView.backgroundColor, with: .red)
    ///
    /// - Parameter atKeyPath: The writable key path pointing to the stored property to update.
    /// - Parameter with: The value to update the property with.
    ///
    /// - Note: This implementation is for Element's stored property being updated having reference
    ///         semantics.
    final func acceptUpdating<Value>(atKeyPath keyPath: WritableKeyPath<Element, Value>, with updatedValue: Value) {
        var newStream = self.value
        newStream[keyPath: keyPath] = updatedValue
        self.accept(newStream)
    }
    
}
