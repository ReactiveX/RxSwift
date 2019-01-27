//
//  AtomicIntBox.swift
//  Platform
//
//  Created by Luciano Almeida on 27/01/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxAtomic

typealias RxAtomicInt = RxAtomic.AtomicInt
public final class AtomicIntBox {

    var value: RxAtomicInt
    
    public init() {
        self.value = RxAtomic.AtomicInt()
        RxAtomicInt.initialize(&self.value, 0)
    }
    
    public init(_ initialValue: Int32) {
        self.value = RxAtomic.AtomicInt()
        RxAtomicInt.initialize(&self.value, initialValue)
    }
    
    @discardableResult
    public func add(_ value: Int32) -> Int32 {
        return RxAtomicInt.add(&self.value, value)
    }
    
    @discardableResult
    public func sub(_ value: Int32) -> Int32 {
        return RxAtomicInt.sub(&self.value, value)
    }
    
    @discardableResult
    public func fetchOr(_ mask: Int32) -> Int32 {
        return RxAtomicInt.fetchOr(&self.value, mask)
    }
    
    public func load() -> Int32 {
        return RxAtomicInt.load(&self.value)
    }
}
