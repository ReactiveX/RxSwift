//
//  RxBox.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Creates immutable reference wrapper for any type.
*/
public class RxBox<T> : CustomStringConvertible {
    /**
    Wrapped value
    */
    public let value : T
    
    /**
    Creates reference wrapper for `value`.
    
    - parameter value: Value to wrap.
    */
    public init (_ value: T) {
        self.value = value
    }
    
    /**
    - returns: Box description.
    */
    public var description: String {
        get {
            return "Box(\(self.value))"
        }
    }
}

/**
Creates mutable reference wrapper for any type.
*/
public class RxMutableBox<T> : CustomStringConvertible {
    /**
    Wrapped value
    */
    public var value : T
    
    /**
    Creates reference wrapper for `value`.
    
    - parameter value: Value to wrap.
    */
    public init (_ value: T) {
        self.value = value
    }
    
    /**
    - returns: Box description.
    */
    public var description: String {
        get {
            return "MutatingBox(\(self.value))"
        }
    }
}
