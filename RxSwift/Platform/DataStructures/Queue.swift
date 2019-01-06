//
//  Queue.swift
//  Platform
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
Data structure that represents queue.

Complexity of `enqueue`, `dequeue` is O(1) when number of operations is
averaged over N operations.

Complexity of `peek` is O(1).
*/
struct Queue<T>: Sequence {
    /// Type of generator.
    typealias Generator = AnyIterator<T>

    private let _resizeFactor = 2
    
    private var _storage: ContiguousArray<T?>
    private var _count = 0
    private var _pushNextIndex = 0
    private let _initialCapacity: Int

    /**
    Creates new queue.
    
    - parameter capacity: Capacity of newly created queue.
    */
    init(capacity: Int) {
        self._initialCapacity = capacity

        self._storage = ContiguousArray<T?>(repeating: nil, count: capacity)
    }
    
    private var dequeueIndex: Int {
        let index = self._pushNextIndex - self.count
        return index < 0 ? index + self._storage.count : index
    }
    
    /// - returns: Is queue empty.
    var isEmpty: Bool {
        return self.count == 0
    }
    
    /// - returns: Number of elements inside queue.
    var count: Int {
        return self._count
    }
    
    /// - returns: Element in front of a list of elements to `dequeue`.
    func peek() -> T {
        precondition(self.count > 0)
        
        return self._storage[self.dequeueIndex]!
    }
    
    mutating private func resizeTo(_ size: Int) {
        var newStorage = ContiguousArray<T?>(repeating: nil, count: size)
        
        let count = self._count
        
        let dequeueIndex = self.dequeueIndex
        let spaceToEndOfQueue = self._storage.count - dequeueIndex
        
        // first batch is from dequeue index to end of array
        let countElementsInFirstBatch = Swift.min(count, spaceToEndOfQueue)
        // second batch is wrapped from start of array to end of queue
        let numberOfElementsInSecondBatch = count - countElementsInFirstBatch
        
        newStorage[0 ..< countElementsInFirstBatch] = self._storage[dequeueIndex ..< (dequeueIndex + countElementsInFirstBatch)]
        newStorage[countElementsInFirstBatch ..< (countElementsInFirstBatch + numberOfElementsInSecondBatch)] = self._storage[0 ..< numberOfElementsInSecondBatch]
        
        self._count = count
        self._pushNextIndex = count
        self._storage = newStorage
    }
    
    /// Enqueues `element`.
    ///
    /// - parameter element: Element to enqueue.
    mutating func enqueue(_ element: T) {
        if self.count == self._storage.count {
            self.resizeTo(Swift.max(self._storage.count, 1) * self._resizeFactor)
        }
        
        self._storage[self._pushNextIndex] = element
        self._pushNextIndex += 1
        self._count += 1
        
        if self._pushNextIndex >= self._storage.count {
            self._pushNextIndex -= self._storage.count
        }
    }
    
    private mutating func dequeueElementOnly() -> T {
        precondition(self.count > 0)
        
        let index = self.dequeueIndex

        defer {
            self._storage[index] = nil
            self._count -= 1
        }

        return self._storage[index]!
    }

    /// Dequeues element or throws an exception in case queue is empty.
    ///
    /// - returns: Dequeued element.
    mutating func dequeue() -> T? {
        if self.count == 0 {
            return nil
        }

        defer {
            let downsizeLimit = self._storage.count / (self._resizeFactor * self._resizeFactor)
            if self._count < downsizeLimit && downsizeLimit >= self._initialCapacity {
                self.resizeTo(self._storage.count / self._resizeFactor)
            }
        }

        return self.dequeueElementOnly()
    }
    
    /// - returns: Generator of contained elements.
    func makeIterator() -> AnyIterator<T> {
        var i = self.dequeueIndex
        var count = self._count

        return AnyIterator {
            if count == 0 {
                return nil
            }

            defer {
                count -= 1
                i += 1
            }

            if i >= self._storage.count {
                i -= self._storage.count
            }

            return self._storage[i]
        }
    }
}
