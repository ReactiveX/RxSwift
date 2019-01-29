//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import RxAtomic

typealias RxAtomicInt = RxAtomic.AtomicInt
final class AtomicInt {
    
    var value: RxAtomicInt
    
    @inline(__always)
    init() {
        self.value = RxAtomic.AtomicInt()
        RxAtomicInt.initialize(&self.value, 0)
    }
    
    @inline(__always)
    init(_ initialValue: Int32) {
        self.value = RxAtomic.AtomicInt()
        RxAtomicInt.initialize(&self.value, initialValue)
    }
    
    @discardableResult
    @inline(__always)
    func add(_ value: Int32) -> Int32 {
        return RxAtomicInt.add(&self.value, value)
    }
    
    @discardableResult
    @inline(__always)
    func sub(_ value: Int32) -> Int32 {
        return RxAtomicInt.sub(&self.value, value)
    }
    
    @discardableResult
    @inline(__always)
    func fetchOr(_ mask: Int32) -> Int32 {
        return RxAtomicInt.fetchOr(&self.value, mask)
    }
    
    @inline(__always)
    func load() -> Int32 {
        return RxAtomicInt.load(&self.value)
    }
    
    @discardableResult
    @inline(__always)
    func increment() -> Int32 {
        return self.add(1)
    }
    
    @discardableResult
    @inline(__always)
    func decrement() -> Int32 {
        return self.sub(1)
    }
    
    @inline(__always)
    func isFlagSet(_ mask: Int32) -> Bool {
        return (self.load() & mask) != 0
    }
}

