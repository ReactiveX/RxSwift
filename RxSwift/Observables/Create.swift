//
//  Create.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    // MARK: create

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
//    public static func create(_ subscribe: @escaping (AnyObserver<E>) -> Disposable) -> Observable<E> {
//        return self.createAnonymous { observer in
//            return subscribe(AnyObserver(eventHandler: observer))
//        }
//    }

    /**
     Creates an observable sequence from a specified subscribe method implementation.

     - seealso: [create operator on reactivex.io](http://reactivex.io/documentation/operators/create.html)

     - parameter subscribe: Implementation of the resulting observable sequence's `subscribe` method.
     - returns: The observable sequence with the specified implementation for the `subscribe` method.
     */
    public static func createAnonymous(_ subscribe: @escaping (Observer<E>) -> Disposable) -> Observable<E> {
        return AnonymousObservable(subscribe)
    }
}

final fileprivate class AnonymousObservable<Element> : Producer<Element> {
    typealias SubscribeHandler = (Observer<Element>) -> Disposable

    let _subscribeHandler: SubscribeHandler

    init(_ subscribeHandler: @escaping SubscribeHandler) {
        _subscribeHandler = subscribeHandler
    }

    override func run(_ observer: Observer<Element>, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {

        let sink = Sink(observer: observer, cancel: cancel)

        var _isStopped: AtomicInt = 0
        // state
        #if DEBUG
            let _synchronizationTracker = SynchronizationTracker()
        #endif

        let subscription = _subscribeHandler(Observer { event in
            #if DEBUG
                _synchronizationTracker.register(synchronizationErrorMessage: .default)
                defer { _synchronizationTracker.unregister() }
            #endif
            switch event {
            case .next:
                if _isStopped == 1 {
                    return
                }
                sink.forwardOn(event)
            case .error, .completed:
                if AtomicCompareAndSwap(0, 1, &_isStopped) {
                    sink.forwardOn(event)
                    sink.dispose()
                }
            }
        })
        return (sink: sink, subscription: subscription)
    }
}
