//
//  Catch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where Error == Swift.Error {
    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    public func catchError(_ handler: @escaping (Swift.Error) throws -> ObservableSource<Element, Completed, Swift.Error>)
        -> ObservableSource<Element, (), Swift.Error> {
        return ObservableSource(run: .run { observer, cancel in
            let source = self.asSource()
            let serialSubscription = SerialDisposable()
            let d1 = SingleAssignmentDisposable()
            serialSubscription.disposable = d1

            let subscription = source.run({ event in
                switch event {
                case .next(let element):
                    observer(.next(element))
                case .completed:
                    observer(.completed(()))
                    cancel.dispose()
                case .error(let error):
                    do {
                        let catchSequence = try handler(error)

                        serialSubscription.disposable = catchSequence.subscribe { event in
                            switch event {
                            case .next(let next):
                                observer(.next(next))
                            case .error(let error):
                                observer(.error(error))
                                cancel.dispose()
                            case .completed:
                                observer(.completed(()))
                                cancel.dispose()
                            }
                        }
                    }
                    catch let error {
                        observer(.error(error))
                        cancel.dispose()
                    }
                }
            }, cancel)

            d1.setDisposable(subscription)

            return serialSubscription
        })
    }
}

extension ObservableType {
    /**
     Continues an observable sequence that is terminated by an error with the observable sequence produced by the handler.
     
     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)
     
     - parameter handler: Error handler function, producing another observable sequence.
     - returns: An observable sequence containing the source sequence's elements, followed by the elements produced by the handler's resulting observable sequence in case an error occurred.
     */
    public func catchError<ResultError>(_ handler: @escaping (Error) -> ObservableSource<Element, Completed, ResultError>)
        -> ObservableSource<Element, Completed, ResultError> {
        return ObservableSource(run: .run { observer, cancel in
            let source = self.asSource()
            let serialSubscription = SerialDisposable()
            let d1 = SingleAssignmentDisposable()
            serialSubscription.disposable = d1

            let subscription = source.run({ event in
                switch event {
                case .next(let element):
                    observer(.next(element))
                case .completed(let completed):
                    observer(.completed(completed))
                    cancel.dispose()
                case .error(let error):
                    let catchSequence = handler(error)
                        
                    serialSubscription.disposable = catchSequence.subscribe { event in
                        switch event {
                        case .next(let next):
                            observer(.next(next))
                        case .error(let error):
                            observer(.error(error))
                            cancel.dispose()
                        case .completed(let completed):
                            observer(.completed(completed))
                            cancel.dispose()
                        }
                    }
                }
            }, cancel)
            
            d1.setDisposable(subscription)
            
            return serialSubscription
        })
    }
}

extension ObservableType {

    /**
     Continues an observable sequence that is terminated by an error with a single element.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - parameter element: Last element in an observable sequence in case error occurs.
     - returns: An observable sequence containing the source sequence's elements, followed by the `element` in case an error occurred.
     */
    public func catchErrorJustReturn<ResultError>(_ element: Element, _ resultError: ResultError.Type)
        -> ObservableSource<Element, Completed, ResultError> {
        return self.catchError { _ in ObservableSource<Element, (), ResultError>.just(element).ignoreCompleted() }
    }
}

extension ObservableType {
    /**
     Continues an observable sequence that is terminated by an error with the next observable sequence.

     - seealso: [catch operator on reactivex.io](http://reactivex.io/documentation/operators/catch.html)

     - returns: An observable sequence containing elements from consecutive source sequences until a source sequence terminates successfully.
     */
//    public static func catchError<SequenceType: Sequence>(_ sequence: SequenceType) -> ObservableSource<Element, Completed, Error>
//        where SequenceType.Iterator.Element == ObservableSource<Element, Completed, Error> {
//        return CatchSequence(sources: sequence)
//    }
}

extension ObservableType {

    /**
     Repeats the source observable sequence until it successfully terminates.

     **This could potentially create an infinite sequence.**

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - returns: Observable sequence to repeat until it successfully terminates.
     */
//    public func retry() -> Observable<E> {
//        return CatchSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()))
//    }

    /**
     Repeats the source observable sequence the specified number of times in case of an error or until it successfully terminates.

     If you encounter an error and want it to retry once, then you must use `retry(2)`

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter maxAttemptCount: Maximum number of times to repeat the sequence.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully.
     */
//    public func retry(_ maxAttemptCount: Int)
//        -> Observable<E> {
//        return CatchSequence(sources: Swift.repeatElement(self.asObservable(), count: maxAttemptCount))
//    }
}
//
//// catch with callback
//
//final private class CatchSinkProxy<O: ObserverType>: ObserverType {
//    typealias E = O.E
//    typealias Parent = CatchSink<O>
//
//    private let _parent: Parent
//
//    init(parent: Parent) {
//        self._parent = parent
//    }
//
//    func on(_ event: Event<E>) {
//        self._parent.forwardOn(event)
//
//        switch event {
//        case .next:
//            break
//        case .error, .completed:
//            self._parent.dispose()
//        }
//    }
//}
//
//final private class CatchSink<O: ObserverType>: Sink<O>, ObserverType {
//    typealias E = O.E
//    typealias Parent = Catch<E>
//
//    private let _parent: Parent
//    private let _subscription = SerialDisposable()
//
//    init(parent: Parent, observer: O, cancel: Cancelable) {
//        self._parent = parent
//        super.init(observer: observer, cancel: cancel)
//    }
//
//    func run() -> Disposable {
//        let d1 = SingleAssignmentDisposable()
//        self._subscription.disposable = d1
//        d1.setDisposable(self._parent._source.subscribe(self))
//
//        return self._subscription
//    }
//
//    func on(_ event: Event<E>) {
//        switch event {
//        case .next:
//            self.forwardOn(event)
//        case .completed:
//            self.forwardOn(event)
//            self.dispose()
//        case .error(let error):
//            do {
//                let catchSequence = try self._parent._handler(error)
//
//                let observer = CatchSinkProxy(parent: self)
//
//                self._subscription.disposable = catchSequence.subscribe(observer)
//            }
//            catch let e {
//                self.forwardOn(.error(e))
//                self.dispose()
//            }
//        }
//    }
//}
//
//final private class Catch<Element>: Producer<Element> {
//    typealias Handler = (Swift.Error) throws -> Observable<Element>
//
//    fileprivate let _source: Observable<Element>
//    fileprivate let _handler: Handler
//
//    init(source: Observable<Element>, handler: @escaping Handler) {
//        self._source = source
//        self._handler = handler
//    }
//
//    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
//        let sink = CatchSink(parent: self, observer: observer, cancel: cancel)
//        let subscription = sink.run()
//        return (sink: sink, subscription: subscription)
//    }
//}
//
//// catch enumerable
//
//final private class CatchSequenceSink<S: Sequence, O: ObserverType>
//    : TailRecursiveSink<S, O>
//    , ObserverType where S.Iterator.Element: ObservableConvertibleType, S.Iterator.Element.E == O.E {
//    typealias Element = O.E
//    typealias Parent = CatchSequence<S>
//
//    private var _lastError: Swift.Error?
//
//    override init(observer: O, cancel: Cancelable) {
//        super.init(observer: observer, cancel: cancel)
//    }
//
//    func on(_ event: Event<Element>) {
//        switch event {
//        case .next:
//            self.forwardOn(event)
//        case .error(let error):
//            self._lastError = error
//            self.schedule(.moveNext)
//        case .completed:
//            self.forwardOn(event)
//            self.dispose()
//        }
//    }
//
//    override func subscribeToNext(_ source: Observable<E>) -> Disposable {
//        return source.subscribe(self)
//    }
//
//    override func done() {
//        if let lastError = self._lastError {
//            self.forwardOn(.error(lastError))
//        }
//        else {
//            self.forwardOn(.completed)
//        }
//
//        self.dispose()
//    }
//
//    override func extract(_ observable: Observable<Element>) -> SequenceGenerator? {
//        if let onError = observable as? CatchSequence<S> {
//            return (onError.sources.makeIterator(), nil)
//        }
//        else {
//            return nil
//        }
//    }
//}
//
//final private class CatchSequence<S: Sequence>: Producer<S.Iterator.Element.E> where S.Iterator.Element: ObservableConvertibleType {
//    typealias Element = S.Iterator.Element.E
//
//    let sources: S
//
//    init(sources: S) {
//        self.sources = sources
//    }
//
//    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
//        let sink = CatchSequenceSink<S, O>(observer: observer, cancel: cancel)
//        let subscription = sink.run((self.sources.makeIterator(), nil))
//        return (sink: sink, subscription: subscription)
//    }
//}
