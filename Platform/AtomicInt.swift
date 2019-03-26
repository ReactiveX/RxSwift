//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxAtomic

typealias AtomicInt = RxAtomic.AtomicInt

extension AtomicInt {
    public init(_ value: Int32) {
        self.init()
        AtomicInt_initialize(&self, value)
    }
}

@discardableResult
@inline(__always)
func add(_ this: UnsafeMutablePointer<AtomicInt>, _ value: Int32) -> Int32 {
    return AtomicInt_add(this, value)
}

@discardableResult
@inline(__always)
func sub(_ this: UnsafeMutablePointer<AtomicInt>, _ value: Int32) -> Int32 {
    return AtomicInt_sub(this, value)
}

@discardableResult
@inline(__always)
func fetchOr(_ this: UnsafeMutablePointer<AtomicInt>, _ mask: Int32) -> Int32 {
    return AtomicInt_fetchOr(this, mask)
}

@inline(__always)
func load(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return AtomicInt_load(this)
}

@discardableResult
@inline(__always)
func increment(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return add(this, 1)
}

@discardableResult
@inline(__always)
func decrement(_ this: UnsafeMutablePointer<AtomicInt>) -> Int32 {
    return sub(this, 1)
}

@inline(__always)
func isFlagSet(_ this: UnsafeMutablePointer<AtomicInt>, _ mask: Int32) -> Bool {
    return (load(this) & mask) != 0
}
