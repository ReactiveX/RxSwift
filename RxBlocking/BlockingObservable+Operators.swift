//
//  BlockingObservable+Operators.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
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
        var elements: [E] = Array<E>()

        var error: Swift.Error?

        let lock = RunLoopLock(timeout: timeout)

        let d = SingleAssignmentDisposable()

        defer {
            d.dispose()
        }

        lock.dispatch {
            let subscription = self.source.subscribe { e in
                if d.isDisposed {
                    return
                }
                switch e {
                case .next(let element):
                    elements.append(element)
                case .error(let e):
                    error = e
                    d.dispose()
                    lock.stop()
                case .completed:
                    d.dispose()
                    lock.stop()
                }
            }

            d.setDisposable(subscription)
        }

        try lock.run()

        if let error = error {
            throw error
        }

        return elements
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence produces first element.
    ///
    /// If sequence terminates with error before producing first element, terminating error will be thrown.
    ///
    /// - returns: First element of sequence. If sequence is empty `nil` is returned.
    public func first() throws -> E? {
        var element: E?

        var error: Swift.Error?

        let d = SingleAssignmentDisposable()

        defer {
            d.dispose()
        }
        
        let lock = RunLoopLock(timeout: timeout)

        lock.dispatch {
            let subscription = self.source.subscribe { e in
                if d.isDisposed {
                    return
                }

                switch e {
                case .next(let e):
                    if element == nil {
                        element = e
                    }
                    break
                case .error(let e):
                    error = e
                default:
                    break
                }

                d.dispose()
                lock.stop()
            }

            d.setDisposable(subscription)
        }

        try lock.run()

        if let error = error {
            throw error
        }

        return element
    }
}

extension BlockingObservable {
    /// Blocks current thread until sequence terminates.
    ///
    /// If sequence terminates with error, terminating error will be thrown.
    ///
    /// - returns: Last element in the sequence. If sequence is empty `nil` is returned.
    public func last() throws -> E? {
        var element: E?

        var error: Swift.Error?

        let d = SingleAssignmentDisposable()

        defer {
            d.dispose()
        }
        
        let lock = RunLoopLock(timeout: timeout)

        lock.dispatch {
            let subscription = self.source.subscribe { e in
                if d.isDisposed {
                    return
                }
                switch e {
                case .next(let e):
                    element = e
                    return
                case .error(let e):
                    error = e
                default:
                    break
                }

                d.dispose()
                lock.stop()
            }

            d.setDisposable(subscription)
        }
        
        try lock.run()
        
        if let error = error {
            throw error
        }
        
        return element
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
        var element: E?
        
        var error: Swift.Error?
        
        let d = SingleAssignmentDisposable()

        defer {
            d.dispose()
        }
        
        let lock = RunLoopLock(timeout: timeout)
        
        lock.dispatch {
            let subscription = self.source.subscribe { e in
                if d.isDisposed {
                    return
                }
                switch e {
                case .next(let e):
                    do {
                        if try !predicate(e) {
                            return
                        }
                        if element == nil {
                            element = e
                        } else {
                            throw RxError.moreThanOneElement
                        }
                    } catch (let err) {
                        error = err
                        d.dispose()
                        lock.stop()
                    }
                    return
                case .error(let e):
                    error = e
                case .completed:
                    if element == nil {
                        error = RxError.noElements
                    }
                }

                d.dispose()
                lock.stop()
            }

            d.setDisposable(subscription)
        }
        
        try lock.run()

        if let error = error {
            throw error
        }
        
        return element
    }
}
