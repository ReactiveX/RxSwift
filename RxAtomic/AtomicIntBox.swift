//
//  AtomicIntBox.swift
//  RxAtomic
//
//  Created by Luciano Almeida on 26/01/19.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

public final class AtomicIntBox {
    @usableFromInline
    var value: AtomicInt
    
    @inlinable
    public init(_ initialValue: Int32) {
        self.value = AtomicInt()
        AtomicInt.initialize(&self.value, initialValue)
    }
    
    @discardableResult
    @inlinable
    public func add(_ value: Int32) -> Int32 {
        return AtomicInt.add(&self.value, value)
    }
    
    @discardableResult
    @inlinable
    public func sub(_ value: Int32) -> Int32 {
        return AtomicInt.sub(&self.value, value)
    }
    
    @discardableResult
    @inlinable
    public func fetchOr(_ mask: Int32) -> Int32 {
        return AtomicInt.fetchOr(&self.value, mask)
    }
    
    @inlinable
    public func load() -> Int32 {
        return AtomicInt.load(&self.value)
    }

}
