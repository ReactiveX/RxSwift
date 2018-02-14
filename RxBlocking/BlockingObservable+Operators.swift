//
//  BlockingObservable+Operators.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

/// The `MaterializedSequenceResult` enum represents the materialized
/// output of a BlockingObservable.
///
/// If the sequence terminates successfully, the result is represented
/// by `.completed` with the array of elements.
///
/// If the sequence terminates with error, the result is represented
/// by `.failed` with both the array of elements and the terminating error.
public enum MaterializedSequenceResult<T> {
    case completed(elements: [T])
    case failed(elements: [T], error: Error)
}

extension MaterializedSequenceResult {
    /// - returns: true if the result is `.completed`, otherwise false.
    public var isCompleted: Bool {
        switch self {
        case .completed: return true
        case .failed: return false
        }
    }

    /// - returns: true if the result is `.failed`, otherwise false.
    public var isFailed: Bool {
        switch self {
        case .completed: return false
        case .failed: return true
        }
    }

    /// - returns: The array of elements.
    public var elements: [T] {
        switch self {
        case .completed(let elements), .failed(let elements, _):
            return elements
        }
    }

    /// - returns: The terminating error if the result is `failed`, otherwise `nil`.
    public var error: Error? {
        switch self {
        case .completed: return nil
        case .failed(_, let error): return error
        }
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error, terminating error will be thrown.
    ///
    /// - returns: All elements of sequence.
    public func toArray() throws -> [E] {
        let results = materializeResult()
        return try elementsOrThrow(results)
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence produces first element.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - returns: First element of sequence. If sequence is empty `nil` is returned.
    public func first() throws -> E? {
        let results = materializeResult(max: 1)
        return try elementsOrThrow(results).first
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error, terminating error will be thrown.
    ///
    /// - returns: Last element in the sequence. If sequence is empty `nil` is returned.
    public func last() throws -> E? {
        let results = materializeResult()
        return try elementsOrThrow(results).last
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - returns: Returns the only element of an sequence, and reports an error if there is not exactly one element in the observable sequence.
    public func single() throws -> E {
        return try single { _ in true }
    }

    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - parameter predicate: A function to test each source element for a condition.
    /// - returns: Returns the only element of an sequence that satisfies the condition in the predicate, and reports an error if there is not exactly one element in the sequence.
    public func single(_ predicate: @escaping (E) throws -> Bool) throws -> E {
        let results = materializeResult(max: 2, predicate: predicate)
        let elements = try elementsOrThrow(results)

        if elements.count > 1 {
            throw RxError.moreThanOneElement
        }

        guard let first = elements.first else {
            throw RxError.noElements
        }

        return first
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// The sequence is materialized as a result type capturing how the sequence terminated (completed or error), along with any elements up to that point.
    ///
    /// - returns: On completion, returns the list of elements in the sequence. On error, returns the list of elements up to that point, along with the error itself.
    public func materialize() -> MaterializedSequenceResult<E> {
        return materializeResult()
    }
}

extension BlockingObservable {
    fileprivate func materializeResult(max: Int? = nil, predicate: @escaping (E) throws -> Bool = { _ in true }) -> MaterializedSequenceResult<E> {
        var elements: [E] = Array<E>()
        var error: Swift.Error?
        
        let lock = RunLoopLock(timeout: timeout)
        
        let d = SingleAssignmentDisposable()
        
        defer {
            d.dispose()
        }
        
        lock.dispatch {
            let subscription = self.source.subscribe { event in
                if d.isDisposed {
                    return
                }
                switch event {
                case .next(let element):
                    do {
                        if try predicate(element) {
                            elements.append(element)
                        }
                        if let max = max, elements.count >= max {
                            d.dispose()
                            lock.stop()
                        }
                    } catch (let err) {
                        error = err
                        d.dispose()
                        lock.stop()
                    }
                case .error(let err):
                    error = err
                    d.dispose()
                    lock.stop()
                case .completed:
                    d.dispose()
                    lock.stop()
                }
            }
            
            d.setDisposable(subscription)
        }
        
        do {
            try lock.run()
        } catch (let err) {
            error = err
        }
        
        if let error = error {
            return MaterializedSequenceResult.failed(elements: elements, error: error)
        }
        
        return MaterializedSequenceResult.completed(elements: elements)
    }
    
    fileprivate func elementsOrThrow(_ results: MaterializedSequenceResult<E>) throws -> [E] {
        switch results {
        case .failed(_, let error):
            throw error
        case .completed(let elements):
            return elements
        }
    }
}
