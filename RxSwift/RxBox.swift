//
//  RxBox.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/22/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Wrapper for any value type
public class RxBox<T> : CustomStringConvertible {
    public let value : T
    public init (_ value: T) {
        self.value = value
    }
    
    public var description: String {
        get {
            return "Box(\(self.value))"
        }
    }
}

// Wrapper for any value type that can be mutated
public class RxMutableBox<T> : CustomStringConvertible {
    public var value : T
    public init (_ value: T) {
        self.value = value
    }
    
    public var description: String {
        get {
            return "MutatingBox(\(self.value))"
        }
    }
}
