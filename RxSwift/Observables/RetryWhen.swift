//
//  RetryWhen.swift
//  RxSwift
//
//  Created by Junior B. on 06/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    func retry<Error: Swift.Error>(when notificationHandler: @escaping (Observable<Error>) -> some ObservableType)
        -> Observable<Element>
    {
        RetryWhenSequence(sources: InfiniteSequence(repeatedValue: asObservable()), notificationHandler: notificationHandler)
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    @available(*, deprecated, renamed: "retry(when:)")
    func retryWhen<Error: Swift.Error>(_ notificationHandler: @escaping (Observable<Error>) -> some ObservableType)
        -> Observable<Element>
    {
        retry(when: notificationHandler)
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    func retry(when notificationHandler: @escaping (Observable<Swift.Error>) -> some ObservableType)
        -> Observable<Element>
    {
        RetryWhenSequence(sources: InfiniteSequence(repeatedValue: asObservable()), notificationHandler: notificationHandler)
    }

    /**
     Repeats the source observable sequence on error when the notifier emits a next value.
     If the source observable errors and the notifier completes, it will complete the source sequence.

     - seealso: [retry operator on reactivex.io](http://reactivex.io/documentation/operators/retry.html)

     - parameter notificationHandler: A handler that is passed an observable sequence of errors raised by the source observable and returns and observable that either continues, completes or errors. This behavior is then applied to the source observable.
     - returns: An observable sequence producing the elements of the given sequence repeatedly until it terminates successfully or is notified to error or complete.
     */
    @available(*, deprecated, renamed: "retry(when:)")
    func retryWhen(_ notificationHandler: @escaping (Observable<Swift.Error>) -> some ObservableType)
        -> Observable<Element>
    {
        RetryWhenSequence(sources: InfiniteSequence(repeatedValue: asObservable()), notificationHandler: notificationHandler)
    }
}

private final class RetryTriggerSink<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType, Error>:
    ObserverType where Sequence.Element: ObservableType, Sequence.Element.Element == Observer.Element
{
    typealias Element = TriggerObservable.Element

    typealias Parent = RetryWhenSequenceSinkIter<Sequence, Observer, TriggerObservable, Error>

    private let parent: Parent

    init(parent: Parent) {
        self.parent = parent
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            parent.parent.lastError = nil
            parent.parent.schedule(.moveNext)
        case let .error(e):
            parent.parent.forwardOn(.error(e))
            parent.parent.dispose()
        case .completed:
            parent.parent.forwardOn(.completed)
            parent.parent.dispose()
        }
    }
}

private final class RetryWhenSequenceSinkIter<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType, Error>:
    ObserverType,
    Disposable where Sequence.Element: ObservableType, Sequence.Element.Element == Observer.Element
{
    typealias Element = Observer.Element
    typealias Parent = RetryWhenSequenceSink<Sequence, Observer, TriggerObservable, Error>

    fileprivate let parent: Parent
    private let errorHandlerSubscription = SingleAssignmentDisposable()
    private let subscription: Disposable

    init(parent: Parent, subscription: Disposable) {
        self.parent = parent
        self.subscription = subscription
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            parent.forwardOn(event)
        case let .error(error):
            parent.lastError = error

            if let failedWith = error as? Error {
                // dispose current subscription
                subscription.dispose()

                let errorHandlerSubscription = parent.notifier.subscribe(RetryTriggerSink(parent: self))
                self.errorHandlerSubscription.setDisposable(errorHandlerSubscription)
                parent.errorSubject.on(.next(failedWith))
            } else {
                parent.forwardOn(.error(error))
                parent.dispose()
            }
        case .completed:
            parent.forwardOn(event)
            parent.dispose()
        }
    }

    final func dispose() {
        subscription.dispose()
        errorHandlerSubscription.dispose()
    }
}

private final class RetryWhenSequenceSink<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType, Error>:
    TailRecursiveSink<Sequence, Observer> where Sequence.Element: ObservableType, Sequence.Element.Element == Observer.Element
{
    typealias Element = Observer.Element
    typealias Parent = RetryWhenSequence<Sequence, TriggerObservable, Error>

    let lock = RecursiveLock()

    private let parent: Parent

    fileprivate var lastError: Swift.Error?
    fileprivate let errorSubject = PublishSubject<Error>()
    private let handler: Observable<TriggerObservable.Element>
    fileprivate let notifier = PublishSubject<TriggerObservable.Element>()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        handler = parent.notificationHandler(errorSubject).asObservable()
        super.init(observer: observer, cancel: cancel)
    }

    override func done() {
        if let lastError {
            forwardOn(.error(lastError))
            self.lastError = nil
        } else {
            forwardOn(.completed)
        }

        dispose()
    }

    override func extract(_: Observable<Element>) -> SequenceGenerator? {
        // It is important to always return `nil` here because there are side effects in the `run` method
        // that are dependent on particular `retryWhen` operator so single operator stack can't be reused in this
        // case.
        nil
    }

    override func subscribeToNext(_ source: Observable<Element>) -> Disposable {
        let subscription = SingleAssignmentDisposable()
        let iter = RetryWhenSequenceSinkIter(parent: self, subscription: subscription)
        subscription.setDisposable(source.subscribe(iter))
        return iter
    }

    override func run(_ sources: SequenceGenerator) -> Disposable {
        let triggerSubscription = handler.subscribe(notifier.asObserver())
        let superSubscription = super.run(sources)
        return Disposables.create(superSubscription, triggerSubscription)
    }
}

private final class RetryWhenSequence<Sequence: Swift.Sequence, TriggerObservable: ObservableType, Error>: Producer<Sequence.Element.Element> where Sequence.Element: ObservableType {
    typealias Element = Sequence.Element.Element

    private let sources: Sequence
    fileprivate let notificationHandler: (Observable<Error>) -> TriggerObservable

    init(sources: Sequence, notificationHandler: @escaping (Observable<Error>) -> TriggerObservable) {
        self.sources = sources
        self.notificationHandler = notificationHandler
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = RetryWhenSequenceSink<Sequence, Observer, TriggerObservable, Error>(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run((sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}
