//
//  RepeatWhen.swift
//  RxSwift
//
//  Created by sergdort on 12/05/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
    Returns an Observable that emits the same values as the source Observable with the exception of an onCompleted. An onCompleted notification from the source will result in the emission of a void item to the Observable provided as an argument to the notificationHandler function. If that Observable calls onComplete or onError then repeatWhen will call onCompleted or onError on the child subscription. Otherwise, this Observable will resubscribe to the source observable.
     
     - parameter notificationHandler: receives an Observable of notifications with which a user can complete or error, aborting the repeat.
     
     - returns: An observable sequence producing the elements of the given sequence repeatedly
    */
    public func repeatWhen<TriggerObservable: ObservableType>(_ notificationHandler: @escaping (Observable<Void>) -> TriggerObservable)
        -> Observable<E> {
            return RepeatWhenSequence(sources: InfiniteSequence(repeatedValue: self.asObservable()), notificationHandler: notificationHandler)
    }
}

final fileprivate class RepeatWhenSequence<S: Sequence, TriggerObservable: ObservableType> : Producer<S.Iterator.Element.E> where S.Iterator.Element : ObservableType {
    typealias Element = S.Iterator.Element.E
    
    fileprivate let _sources: S
    fileprivate let _notificationHandler: (Observable<Void>) -> TriggerObservable
    
    init(sources: S, notificationHandler: @escaping (Observable<Void>) -> TriggerObservable) {
        _sources = sources
        _notificationHandler = notificationHandler
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = RepeatWhenSequenceSink<S, O, TriggerObservable>(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run((self._sources.makeIterator(), nil))
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class RepeatWhenSequenceSink<S: Sequence, O: ObserverType, TriggerObservable: ObservableType>
    : TailRecursiveSink<S, O> where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E {
    typealias Element = O.E
    typealias Parent = RepeatWhenSequence<S, TriggerObservable>
    
    let _lock = RecursiveLock()
    
    fileprivate let _parent: Parent
    fileprivate let _completeSubject = PublishSubject<Void>()
    fileprivate let _handler: Observable<TriggerObservable.E>
    fileprivate let _notifier = PublishSubject<TriggerObservable.E>()
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        _handler = parent._notificationHandler(_completeSubject).asObservable()
        super.init(observer: observer, cancel: cancel)
    }
    
    override func done() {
        forwardOn(.completed)
        dispose()
    }
    
    override func extract(_ observable: Observable<E>) -> SequenceGenerator? {
        // It is important to always return `nil` here because there are sideffects in the `run` method
        // that are dependant on particular `retryWhen` operator so single operator stack can't be reused in this
        // case.
        return nil
    }
    
    override func subscribeToNext(_ source: Observable<E>) -> Disposable {
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

final fileprivate class RepeatWhenSequenceSinkIter<S: Sequence, O: ObserverType, TriggerObservable: ObservableType>
    : ObserverType
    , Disposable where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E {
    typealias E = O.E
    typealias Parent = RepeatWhenSequenceSink<S, O, TriggerObservable>
    
    fileprivate let _parent: Parent
    fileprivate let _completeHandlerSubscription = SingleAssignmentDisposable()
    fileprivate let _subscription: Disposable
    
    init(parent: Parent, subscription: Disposable) {
        _parent = parent
        _subscription = subscription
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            _parent.forwardOn(event)
        case .error(let error):
            _subscription.dispose()
            _parent.forwardOn(.error(error))
            _parent.dispose()
        case .completed:
            _subscription.dispose()
            let completeHandlerSubscription = _parent._notifier.subscribe(RepeatTriggerSink(parent: self))
            _completeHandlerSubscription.setDisposable(completeHandlerSubscription)
            _parent._completeSubject.on(.next())
        }
    }
    
    final func dispose() {
        _subscription.dispose()
        _completeHandlerSubscription.dispose()
    }
}

final fileprivate class RepeatTriggerSink<S: Sequence, O: ObserverType, TriggerObservable: ObservableType>
    : ObserverType where S.Iterator.Element : ObservableType, S.Iterator.Element.E == O.E {
    typealias E = TriggerObservable.E
    
    typealias Parent = RepeatWhenSequenceSinkIter<S, O, TriggerObservable>
    
    fileprivate let _parent: Parent
    
    init(parent: Parent) {
        _parent = parent
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next:
            _parent._parent.schedule(.moveNext)
        case .error(let e):
            _parent._parent.forwardOn(.error(e))
            _parent._parent.dispose()
        case .completed:
            _parent._parent.forwardOn(.completed)
            _parent._parent.dispose()
        }
    }
}

