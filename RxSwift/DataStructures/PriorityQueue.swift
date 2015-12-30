//
//  PriorityQueue.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct PriorityQueue<Element: AnyObject> {
    private let _hasHigherPriority: (Element, Element) -> Bool
    private var _elements = [Element]()

    init(hasHigherPriority: (Element, Element) -> Bool) {
        _hasHigherPriority = hasHigherPriority
    }

    mutating func enqueue(element: Element) {
        _elements.append(element)
        bubbleToHigherPriority(_elements.count - 1)
    }

    func peek() -> Element? {
        return _elements.first
    }

    var isEmpty: Bool {
        return _elements.count == 0
    }

    mutating func dequeue() -> Element? {
        guard let front = peek() else {
            return nil
        }

        removeAt(0)

        return front
    }

    mutating func remove(element: Element) {
        for i in 0 ..< _elements.count {
            if _elements[i] === element {
                removeAt(i)
                return
            }
        }
    }

    private mutating func removeAt(index: Int) {
        let removingLast = index == _elements.count - 1
        if !removingLast {
            swap(&_elements[index], &_elements[_elements.count - 1])
        }

        _elements.popLast()

        if !removingLast {
            bubbleToHigherPriority(index)
            bubbleToLowerPriority(index)
        }
    }

    private mutating func bubbleToHigherPriority(initialUnbalancedIndex: Int) {
        precondition(initialUnbalancedIndex >= 0)
        precondition(initialUnbalancedIndex < _elements.count)

        var unbalancedIndex = initialUnbalancedIndex

        while unbalancedIndex > 0 {
            let parentIndex = (unbalancedIndex - 1) / 2

            if _hasHigherPriority(_elements[unbalancedIndex], _elements[parentIndex]) {
                swap(&_elements[unbalancedIndex], &_elements[parentIndex])

                unbalancedIndex = parentIndex
            }
            else {
                break
            }
        }
    }

    private mutating func bubbleToLowerPriority(initialUnbalancedIndex: Int) {
        precondition(initialUnbalancedIndex >= 0)
        precondition(initialUnbalancedIndex < _elements.count)

        var unbalancedIndex = initialUnbalancedIndex
        repeat {
            let leftChildIndex = unbalancedIndex * 2 + 1
            let rightChildIndex = unbalancedIndex * 2 + 2

            var highestPriorityIndex = unbalancedIndex

            if leftChildIndex < _elements.count && _hasHigherPriority(_elements[leftChildIndex], _elements[highestPriorityIndex]) {
                highestPriorityIndex = leftChildIndex
            }

            if rightChildIndex < _elements.count && _hasHigherPriority(_elements[rightChildIndex], _elements[highestPriorityIndex]) {
                highestPriorityIndex = rightChildIndex
            }

            if highestPriorityIndex != unbalancedIndex {
                swap(&_elements[highestPriorityIndex], &_elements[unbalancedIndex])

                unbalancedIndex = highestPriorityIndex
            }
            else {
                break
            }
        } while true
    }
}

extension PriorityQueue : CustomDebugStringConvertible {
    var debugDescription: String {
        return _elements.debugDescription
    }
}