//
//  BlockingObservable+Operators.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !RX_NO_MODULE
    import RxSwift
#endif

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error, terminating error will be thrown.
    ///
    /// - returns: All elements of sequence.
    public func toArray() throws -> [E] {
        return try convertToArray()
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence produces first element.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - returns: First element of sequence. If sequence is empty `nil` is returned.
    public func first() throws -> E? {
        return try convertToArray(max: 1).first
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error, terminating error will be thrown.
    ///
    /// - returns: Last element in the sequence. If sequence is empty `nil` is returned.
    public func last() throws -> E? {
        return try convertToArray().last
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - returns: Returns the only element of an sequence, and reports an error if there is not exactly one element in the observable sequence.
    public func single() throws -> E? {
        return try single { _ in true }
    }

    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - parameter predicate: A function to test each source element for a condition.
    /// - returns: Returns the only element of an sequence that satisfies the condition in the predicate, and reports an error if there is not exactly one element in the sequence.
    public func single(_ predicate: @escaping (E) throws -> Bool) throws -> E? {
        let elements = try convertToArray(max: 2, predicate: predicate)
        
        switch elements.count {
        case 0:
            throw RxError.noElements
        case 1:
            return elements.first
        default:
            throw RxError.moreThanOneElement
        }
    }
}

extension BlockingObservable {
    fileprivate func convertToArray(max: Int? = nil, predicate: @escaping (E) throws -> Bool = { _ in true }) throws -> [E] {
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
            throw error
        }
        
        return elements
    }
}
