//
//  Catch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    public func catchError(_ handler: @escaping (Swift.Error) throws -> Observable<E>)
        -> Observable<E> {
        return Catch(source: asObservable(), handler: handler)
    }

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    public func catchErrorJustReturn(_ element: E)
        -> Observable<E> {
        return Catch(source: asObservable(), handler: { _ in Observable.just(element) })
    }
    
}

extension ObservableType {
    /**
     Continues an observable sequence that is terminated by an error with the next observable sequence.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
     */
    public static func catchError<S: Sequence>(_ sequence: S) -> Observable<E>
        where S.Iterator.Element == Observable<E> {
        return CatchSequence(sources: sequence)
    }
}

extension ObservableType {

    /**
     Repeats the source observable sequence until it successfully terminates.

     **This could potentially create an infinite sequence.**

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - returns: Observable sequence to repeat until it successfully terminates.
     */
    public func retry() -> Observable<E> {
        return CatchSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()))
    }

    /**
     Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.

     If you encounter an error and want it to retry once, then you must use `retry(2)`

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to repeat the sequence.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
    public func retry(_ maxAttemptCount: Int)
        -> Observable<E> {
        return CatchSequence(sources: Swift.repeatElement(self.asObservable(), count: maxAttemptCount))
    }
}

final fileprivate class Catch<Element> : Producer<Element> {
    typealias Handler = (Swift.Error) throws -> Observable<Element>
    
    fileprivate let _source: Observable<Element>
    fileprivate let _handler: Handler
    
    init(source: Observable<Element>, handler: @escaping Handler) {
        _source = source
        _handler = handler
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = SerialDisposable()
        let d1 = SingleAssignmentDisposable()
        subscription.disposable = d1
        d1.setDisposable(_source.subscribe { event in
                switch event {
                case .next:
                    sink.forwardOn(event)
                case .completed:
                    sink.forwardOn(event)
                    sink.dispose()
                case .error(let error):
                    do {
                        let catchSequence = try self._handler(error)

                        subscription.disposable = catchSequence.subscribe { event in
                            sink.forwardOn(event)

                            switch event {
                            case .next:
                                break
                            case .error, .completed:
                                sink.dispose()
                            }
                        }
                    }
                    catch let e {
                        sink.forwardOn(.error(e))
                        sink.dispose()
                    }
                }
        })

        return (sink: sink, subscription: subscription)
    }
}

// catch enumerable

final fileprivate class CatchSequenceSink<S: Sequence>
    : TailRecursiveSink<S> where S.Iterator.Element : ObservableConvertibleType {
    typealias Element = S.Iterator.Element.E
    typealias Parent = CatchSequence<S>
    
    private var _lastError: Swift.Error?
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            forwardOn(event)
        case .error(let error):
            _lastError = error
            schedule(.moveNext)
        case .completed:
            forwardOn(event)
            dispose()
        }
    }

    override func subscribeToNext(_ source: Observable<E>) -> Disposable {
        return source.subscribe(self.on)
    }
    
    override func done() {
        if let lastError = _lastError {
            forwardOn(.error(lastError))
        }
        else {
            forwardOn(.completed)
        }
        
        self.dispose()
    }
    
    override func extract(_ observable: Observable<Element>) -> SequenceGenerator? {
        if let onError = observable as? CatchSequence<S> {
            return (onError.sources.makeIterator(), nil)
        }
        else {
            return nil
        }
    }
}

final fileprivate class CatchSequence<S: Sequence> : Producer<S.Iterator.Element.E> where S.Iterator.Element : ObservableConvertibleType {
    typealias Element = S.Iterator.Element.E
    
    let sources: S
    
    init(sources: S) {
        self.sources = sources
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = CatchSequenceSink<S>(observer: observer, cancel: cancel)
        let subscription = sink.run((self.sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}
