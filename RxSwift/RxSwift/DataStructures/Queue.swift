//
//  Queue.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct Queue<T>: SequenceType {
    typealias Generator = GeneratorOf<T>
    
    let resizeFactor = 2
    
    private var storage: [T?]
    private var _count: Int
    private var pushNextIndex: Int
    private var initialCapacity: Int
    private var version: Int
    
    public init(capacity: Int) {
        initialCapacity = capacity
        
        version = 0
        storage = []
        _count = 0
        pushNextIndex = 0
        
        resizeTo(capacity)
    }
    
    private var dequeueIndex: Int {
        get {
            var index = pushNextIndex - count
            return index < 0 ? index + self.storage.count : index
        }
    }
    
    public var count: Int {
        get {
            return _count
        }
    }
    
    public func peek() -> T {
        contract(count > 0)
        
        return storage[dequeueIndex]!
    }
    
    mutating private func resizeTo(size: Int) {
        var newStorage: [T?] = []
        newStorage.reserveCapacity(size)
        
        var count = _count
        
        for var i = 0; i < count; ++i {
            // does swift array have some more efficient methods of copying?
            newStorage.append(dequeue())
        }
        
        while newStorage.count < size {
            newStorage.append(nil)
        }
        
        _count = count
        pushNextIndex = count
        storage = newStorage
    }
    
    public mutating func enqueue(item: T) {
        version++
        
        let queueFull = count == storage.count
        if count == storage.count {
            resizeTo(storage.count * resizeFactor)
        }
        
        storage[pushNextIndex] = item
        pushNextIndex++
        _count = _count + 1
        
        if pushNextIndex >= storage.count {
            pushNextIndex -= storage.count
        }
    }
    
    public mutating func dequeue() -> T {
        version++
        
        contract(count > 0)
       
        let index = dequeueIndex
        let value = storage[index]!
        
        storage[index] = nil
        
        _count = _count - 1
        
        let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
        if _count < downsizeLimit && downsizeLimit >= initialCapacity {
            resizeTo(storage.count / resizeFactor)
        }
        
        return value
    }
    
    public func generate() -> Generator {
        var i = dequeueIndex
        var count = _count
        
        var lastVersion = version
        
        return GeneratorOf {
            if lastVersion != self.version {
                rxFatalError("Collection was modified while enumerated")
            }
            
            if count == 0 {
                return nil
            }
            
            count--
            if i >= self.storage.count {
                i -= self.storage.count
            }
            
            return self.storage[i++]
        }
    }
}