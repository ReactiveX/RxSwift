//
//  Breakpoint.swift
//  RxSwift
//
//  Created by Anton Nazarov on 09/06/19.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension ObservableType {
    /**
     Raises a debugger signal when a provided closure needs to stop the process in the debugger.
     - seealso: [breakpoint operator on Combine](https://developer.apple.com/documentation/combine/publisher/3204688-breakpoint)

     - parameter onNext: Predicate to invoke for each element in the observable sequence.  Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter afterNext: Predicate to invoke for each element after the observable has passed an onNext event along to its downstream. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter onError: Predicate to invoke upon errored termination of the observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter afterError: Predicate to invoke after errored termination of the observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter onCompleted: Predicate to invoke upon graceful termination of the observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter afterCompleted: Predicate to invoke after graceful termination of the observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter onSubscribe: Predicate to invoke before subscribing to source observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter onSubscribed: Predicate to invoke after subscribing to source observable sequence. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - parameter onDispose: Predicate to invoke after subscription to source observable has been disposed for any reason. It can be either because sequence terminates for some reason or observer subscription being disposed. Return `true` from this closure to raise `SIGTRAP`, or false to continue.
     - returns: The source sequence that raises a debugger signal when one of the provided closures returns `true`.
     */
    public func breakpoint(
        onNext: @escaping (Element) throws -> Bool = { _ in false },
        afterNext: @escaping (Element) throws -> Bool = { _ in false },
        onError: @escaping (Swift.Error) throws -> Bool = { _ in false },
        afterError: @escaping (Swift.Error) throws -> Bool = { _ in false },
        onCompleted: @escaping @autoclosure () throws -> Bool = false,
        afterCompleted: @escaping @autoclosure () throws -> Bool = false,
        onSubscribe: @escaping @autoclosure () -> Bool = false,
        onSubscribed: @escaping @autoclosure () -> Bool = false,
        onDispose: @escaping @autoclosure () -> Bool = false
    ) -> Observable<Element> {
        return Breakpoint(
            source: self.asObservable(),
            eventPredicate: {
                switch $0 {
                case let .next(element):
                    return try onNext(element)
                case let .error(error):
                    return try onError(error)
                case .completed:
                    return try onCompleted()
                }
            },
            afterEventPredicate:  {
                switch $0 {
                case let .next(element):
                    return try afterNext(element)
                case let .error(error):
                    return try afterError(error)
                case .completed:
                    return try afterCompleted()
                }
            },
            onSubscribe: onSubscribe(),
            onSubscribed: onSubscribed(),
            onDispose: onDispose()
        )
    }

    /**
      Raises a debugger signal upon receiving an error.
      When the upstream Observable fails with an error, this operator raises the `SIGTRAP` signal, which stops the process in the debugger.
      Otherwise, this Observable passes through values and completions as-is.
      - seealso: [breakpointOnError operator on Combine](https://developer.apple.com/documentation/combine/publisher/3204689-breakpointonerror)
      - returns: An Observable that raises a debugger signal upon receiving a failure.
      */
    public func breakpointOnError() -> Observable<Element> {
        return Breakpoint(
            source: self.asObservable(),
            eventPredicate: { $0.error != nil },
            afterEventPredicate: { _ in false }
        )
    }
}

#if DEBUG
private func raiseBreakpoint() {
    raise(SIGTRAP)
}
#endif

final private class BreakpointSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element
    typealias EventPredicate = (Event<Element>) throws -> Bool
    typealias AfterEventPredicate = (Event<Element>) throws -> Bool

    private let _eventPredicate: EventPredicate
    private let _afterEventPredicate: AfterEventPredicate

    init(eventPredicate: @escaping EventPredicate, afterEventPredicate: @escaping AfterEventPredicate, observer: Observer, cancel: Cancelable) {
        self._eventPredicate = eventPredicate
        self._afterEventPredicate = afterEventPredicate
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        do {
            #if DEBUG
            if try self._eventPredicate(event) {
                raiseBreakpoint()
            }
            #endif
            self.forwardOn(event)
            #if DEBUG
            if try self._afterEventPredicate(event) {
                raiseBreakpoint()
            }
            #endif
            if event.isStopEvent {
                self.dispose()
            }
        }
        catch let error {
            self.forwardOn(.error(error))
            self.dispose()
        }
    }
}

final private class Breakpoint<Element>: Producer<Element> {
    typealias EventPredicate = (Event<Element>) throws -> Bool
    typealias AfterEventPredicate = (Event<Element>) throws -> Bool

    fileprivate let _source: Observable<Element>
    fileprivate let _eventPredicate: EventPredicate
    fileprivate let _afterEventPredicate: EventPredicate
    fileprivate let _onSubscribe: () -> Bool
    fileprivate let _onSubscribed: () -> Bool
    fileprivate let _onDispose: () -> Bool

    init(
        source: Observable<Element>,
        eventPredicate: @escaping EventPredicate,
        afterEventPredicate: @escaping AfterEventPredicate,
        onSubscribe: @escaping @autoclosure () -> Bool = false,
        onSubscribed: @escaping @autoclosure () -> Bool = false,
        onDispose: @escaping @autoclosure () -> Bool = false
    ) {
        self._source = source
        self._eventPredicate = eventPredicate
        self._afterEventPredicate = afterEventPredicate
        self._onSubscribe = onSubscribe
        self._onSubscribed = onSubscribed
        self._onDispose = onDispose
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Element == Observer.Element {
        #if DEBUG
        if _onSubscribe() {
            raiseBreakpoint()
        }
        #endif
        let sink = BreakpointSink(eventPredicate: self._eventPredicate, afterEventPredicate: self._afterEventPredicate, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        #if DEBUG
        if _onSubscribed() {
            raiseBreakpoint()
        }
        #endif
        let allSubscriptions = Disposables.create {
            subscription.dispose()
            #if DEBUG
            guard self._onDispose() else { return }
            raiseBreakpoint()
            #endif
        }
        return (sink: sink, subscription: allSubscriptions)
    }
}
