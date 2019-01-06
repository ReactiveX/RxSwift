//
//  PriorityQueue.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

struct PriorityQueue<Element> {
    private let _hasHigherPriority: (Element, Element) -> Bool
    private let _isEqual: (Element, Element) -> Bool

    fileprivate var _elements = [Element]()

    init(hasHigherPriority: @escaping (Element, Element) -> Bool, isEqual: @escaping (Element, Element) -> Bool) {
        self._hasHigherPriority = hasHigherPriority
        self._isEqual = isEqual
    }

    mutating func enqueue(_ element: Element) {
        self._elements.append(element)
        self.bubbleToHigherPriority(self._elements.count - 1)
    }

    func peek() -> Element? {
        return self._elements.first
    }

    var isEmpty: Bool {
        return self._elements.count == 0
    }

    mutating func dequeue() -> Element? {
        guard let front = self.peek() else {
            return nil
        }

        self.removeAt(0)

        return front
    }

    mutating func remove(_ element: Element) {
        for i in 0 ..< self._elements.count {
            if self._isEqual(self._elements[i], element) {
                self.removeAt(i)
                return
            }
        }
    }

    private mutating func removeAt(_ index: Int) {
        let removingLast = index == self._elements.count - 1
        if !removingLast {
            self._elements.swapAt(index, self._elements.count - 1)
        }

        _ = self._elements.popLast()

        if !removingLast {
            self.bubbleToHigherPriority(index)
            self.bubbleToLowerPriority(index)
        }
    }

    private mutating func bubbleToHigherPriority(_ initialUnbalancedIndex: Int) {
        precondition(initialUnbalancedIndex >= 0)
        precondition(initialUnbalancedIndex < self._elements.count)

        var unbalancedIndex = initialUnbalancedIndex

        while unbalancedIndex > 0 {
            let parentIndex = (unbalancedIndex - 1) / 2
            guard self._hasHigherPriority(self._elements[unbalancedIndex], self._elements[parentIndex]) else { break }
            self._elements.swapAt(unbalancedIndex, parentIndex)
            unbalancedIndex = parentIndex
        }
    }

    private mutating func bubbleToLowerPriority(_ initialUnbalancedIndex: Int) {
        precondition(initialUnbalancedIndex >= 0)
        precondition(initialUnbalancedIndex < self._elements.count)

        var unbalancedIndex = initialUnbalancedIndex
        while true {
            let leftChildIndex = unbalancedIndex * 2 + 1
            let rightChildIndex = unbalancedIndex * 2 + 2

            var highestPriorityIndex = unbalancedIndex

            if leftChildIndex < self._elements.count && self._hasHigherPriority(self._elements[leftChildIndex], self._elements[highestPriorityIndex]) {
                highestPriorityIndex = leftChildIndex
            }

            if rightChildIndex < self._elements.count && self._hasHigherPriority(self._elements[rightChildIndex], self._elements[highestPriorityIndex]) {
                highestPriorityIndex = rightChildIndex
            }

            guard highestPriorityIndex != unbalancedIndex else { break }
            self._elements.swapAt(highestPriorityIndex, unbalancedIndex)

            unbalancedIndex = highestPriorityIndex
        }
    }
}

extension PriorityQueue: CustomDebugStringConvertible {
    var debugDescription: String {
        return self._elements.debugDescription
    }
}
