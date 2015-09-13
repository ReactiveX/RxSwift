//
//  Queue.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Data structure that represents queue.

Complexity of `enqueue`, `dequeue` is O(1) when number of operations is
averaged over N operations.

Complexity of `peek` is O(1).
*/
public struct Queue<T>: SequenceType {
    /**
    Type of generator.
    */
    public typealias Generator = AnyGenerator<T>
    
    let resizeFactor = 2
    
    private var storage: [T?]
    private var _count: Int
    private var pushNextIndex: Int
    private var initialCapacity: Int
    private var version: Int
    
    /**
    Creates new queue.
    
    - parameter capacity: Capacity of newly created queue.
    */
    public init(capacity: Int) {
        initialCapacity = capacity
        
        version = 0
        _count = 0
        pushNextIndex = 0
     
        if capacity > 0 {
            storage = [T?](count: capacity, repeatedValue: nil)
        }
        else {
            storage = []
        }
    }
    
    private var dequeueIndex: Int {
        get {
           let index = pushNextIndex - count
            return index < 0 ? index + self.storage.count : index
        }
    }
    
    /**
    - returns: Is queue empty.
    */
    public var empty: Bool {
        get {
            return count == 0
        }
    }
    
    /**
    - returns: Number of elements inside queue.
    */
    public var count: Int {
        get {
            return _count
        }
    }
    
    /**
    - returns: Element in front of a list of elements to `dequeue`.
    */
    public func peek() -> T {
        precondition(count > 0)
        
        return storage[dequeueIndex]!
    }
    
    mutating private func resizeTo(size: Int) {
        var newStorage = [T?](count: size, repeatedValue: nil)
        
        let count = _count
        
        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = self.storage.count - dequeueIndex
        
        // first batch is from dequeue index to end of array
        let countElementsInFirstBatch = min(count, spaceToEndOfQueue)
        // second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0 ..< countElementsInFirstBatch] = self.storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = self.storage[0 ..< numberOfElementsInSecondBatch]
        
        _count = count
        pushNextIndex = count
        storage = newStorage
    }
    
    /**
    Enqueues `element`.
    
    - parameter element: Element to enqueue.
    */
    public mutating func enqueue(element: T) {
        version++
        
        if count == storage.count {
            resizeTo(max(storage.count, 1) * resizeFactor)
        }
        
        storage[pushNextIndex] = element
        pushNextIndex++
        _count = _count + 1
        
        if pushNextIndex >= storage.count {
            pushNextIndex -= storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(count > 0)
        
        version++
        
        let index = dequeueIndex
        let value = storage[index]!
        
        storage[index] = nil
        
        _count = _count - 1
        
        return value
    }
    
    /**
    Dequeues element and returns it, or returns `nil` in case queue is empty.
    
    - returns: Dequeued element.
    */
    public mutating func tryDequeue() -> T? {
        if self.count == 0 {
            return nil
        }
        
        return dequeue()
    }
    
    /**
    Dequeues element or throws an exception in case queue is empty.
    
    - returns: Dequeued element.
    */
    public mutating func dequeue() -> T {
        let value = dequeueElementOnly()
        
        let downsizeLimit = storage.count / (resizeFactor * resizeFactor)
        if _count < downsizeLimit && downsizeLimit >= initialCapacity {
            resizeTo(storage.count / resizeFactor)
        }
        
        return value
    }
    
    /**
    - returns: Generator of contained elements.
    */
    public func generate() -> Generator {
        var i = dequeueIndex
        var count = _count
        
        let lastVersion = version
        
        return anyGenerator {
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