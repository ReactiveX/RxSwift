//
//  RepeatWhen.swift
//  RxSwift
//
//  Created by sergdort on 12/05/2017.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Returns an Observable that emits the same values as the source Observable with the exception of an onCompleted. An onCompleted notification from the source will result in the emission of a void item to the Observable provided as an argument to the notificationHandler function. If that Observable calls onComplete or onError then repeatWhen will call onCompleted or onError on the child subscription. Otherwise, this Observable will resubscribe to the source observable.

     - seealso: [repeat operator on reactivex.io](http://reactivex.io/documentation/operators/repeat.html)

     - parameter notificationHandler: receives an Observable of notifications with which a user can complete or error, aborting the repeat.

     - returns: An observable sequence producing the elements of the given sequence repeatedly
     */
    public func repeatWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Void>) -> TriggerObservable)
        -> Observable<Element> {
            return RepeatWhenSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }
}

final fileprivate class RepeatWhenSequence<Sequence: Swift.Sequence, TriggerObservable: ObservableType> : Producer<Sequence.Iterator.Element.Element> where Sequence.Iterator.Element : ObservableType {
    typealias Element = Sequence.Iterator.Element.Element

    fileprivate let _sources: Sequence
    fileprivate let _notificationHandler: (Observable<Void>) -> TriggerObservable

    init(sources: Sequence, notificationHandler: @escaping (Observable<Void>) -> TriggerObservable) {
        _sources = sources
        _notificationHandler = notificationHandler
    }

    override func run<Observer : ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = RepeatWhenSequenceSink<Sequence, Observer, TriggerObservable>(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run((self._sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class RepeatWhenSequenceSink<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType>
    : TailRecursiveSink<Sequence, Observer> where Sequence.Iterator.Element : ObservableType, Sequence.Iterator.Element.Element == Observer.Element {
    typealias Element = Observer.Element
    typealias Parent = RepeatWhenSequence<Sequence, TriggerObservable>

    let _lock = RecursiveLock()

    fileprivate let _parent: Parent
    fileprivate let _completeSubject = PublishSubject<Void>()
    fileprivate let _handler: Observable<TriggerObservable.Element>
    fileprivate let _notifier = PublishSubject<TriggerObservable.Element>()

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        _parent = parent
        _handler = parent._notificationHandler(_completeSubject).asObservable()
        super.init(observer: observer, cancel: cancel)
    }

    override func done() {
        forwardOn(.completed)
        dispose()
    }

    override func extract(_ observable: Observable<Element>) -> SequenceGenerator? {
        // It is important to always return `nil` here because there are sideffects in the `run` method
        // that are dependant on particular `retryWhen` operator so single operator stack can't be reused in this
        // case.
        return nil
    }

    override func subscribeToNext(_ source: Observable<Element>) -> Disposable {
        let subscription = SingleAssignmentDisposable()
        let iter = RepeatWhenSequenceSinkIter(parent: self, subscription: subscription)
        subscription.setDisposable(source.subscribe(iter))
        return iter
    }

    override func run(_ sources: SequenceGenerator) -> Disposable {
        let triggerSubscription = _handler.subscribe(_notifier.asObserver())
        let superSubscription = super.run(sources)
        return Disposables.create(superSubscription, triggerSubscription)
    }
}

final fileprivate class RepeatWhenSequenceSinkIter<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType>
    : ObserverType
    , Disposable where Sequence.Iterator.Element : ObservableType, Sequence.Iterator.Element.Element == Observer.Element {
    typealias Element = Observer.Element
    typealias Parent = RepeatWhenSequenceSink<Sequence, Observer, TriggerObservable>

    fileprivate let _parent: Parent
    fileprivate let _completeHandlerSubscription = SingleAssignmentDisposable()
    fileprivate let _subscription: Disposable

    init(parent: Parent, subscription: Disposable) {
        _parent = parent
        _subscription = subscription
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            _parent.forwardOn(event)
        case let .error(error):
            _subscription.dispose()
            _parent.forwardOn(.error(error))
            _parent.dispose()
        case .completed:
            _subscription.dispose()
            let completeHandlerSubscription = _parent._notifier.subscribe(RepeatTriggerSink(parent: self))
            _completeHandlerSubscription.setDisposable(completeHandlerSubscription)
            _parent._completeSubject.on(.next(()))
        }
    }

    final func dispose() {
        _subscription.dispose()
        _completeHandlerSubscription.dispose()
    }
}

final fileprivate class RepeatTriggerSink<Sequence: Swift.Sequence, Observer: ObserverType, TriggerObservable: ObservableType>
    : ObserverType where Sequence.Iterator.Element : ObservableType, Sequence.Iterator.Element.Element == Observer.Element {
    typealias Element = TriggerObservable.Element
    typealias Parent = RepeatWhenSequenceSinkIter<Sequence, Observer, TriggerObservable>

    fileprivate let _parent: Parent

    init(parent: Parent) {
        _parent = parent
    }

    func on(_ event: Event<Element>) {
        switch event {
        case .next:
            _parent._parent.schedule(.moveNext)
        case let .error(error):
            _parent._parent.forwardOn(.error(error))
            _parent._parent.dispose()
        case .completed:
            _parent._parent.forwardOn(.completed)
            _parent._parent.dispose()
        }
    }
}
