//
//  AtomicInt.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/28/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

typealias AtomicInt = AtomicIntBox

extension AtomicInt {
    @discardableResult
    func increment() -> Int32 {
        return self.add(1)
    }

    @discardableResult
    func decrement() -> Int32 {
        return self.sub(1)
    }

    func isFlagSet(_ mask: Int32) -> Bool {
        return (self.load() & mask) != 0
    }
}

