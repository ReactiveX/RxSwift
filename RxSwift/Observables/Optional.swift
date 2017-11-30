//
//  Optional.swift
//  RxSwift
//
//  Created by tarunon on 2016/12/13.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    public static func from(optional: E?) -> Observable<E> {
        return ObservableOptional(optional: optional)
    }

    /**
     Converts a optional to an observable sequence.

     - seealso: [from operator on reactivex.io](http://reactivex.io/documentation/operators/from.html)

     - parameter optional: Optional element in the resulting observable sequence.
     - parameter: Scheduler to send the optional element on.
     - returns: An observable sequence containing the wrapped value or not from given optional.
     */
    public static func from(optional: E?, scheduler: ImmediateSchedulerType) -> Observable<E> {
        return ObservableOptionalScheduled(optional: optional, scheduler: scheduler)
    }
}

final fileprivate class ObservableOptionalScheduledSink<O: ObserverType> : Sink<O> {
    typealias E = O.E
    typealias Parent = ObservableOptionalScheduled<E>

    private let _parent: Parent

    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        return _parent._scheduler.schedule(_parent._optional) { (optional: E?) -> Disposable in
            if let next = optional {
                self.forwardOn(.next(next))
                return self._parent._scheduler.schedule(()) { _ in
                    self.forwardOn(.completed)
                    self.dispose()
                    return Disposables.create()
                }
            } else {
                self.forwardOn(.completed)
                self.dispose()
                return Disposables.create()
            }
        }
    }
}

final fileprivate class ObservableOptionalScheduled<E> : Producer<E> {
    fileprivate let _optional: E?
    fileprivate let _scheduler: ImmediateSchedulerType

    init(optional: E?, scheduler: ImmediateSchedulerType) {
        _optional = optional
        _scheduler = scheduler
    }

    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == E {
        let sink = ObservableOptionalScheduledSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class ObservableOptional<E>: Producer<E> {
    private let _optional: E?
    
    init(optional: E?) {
        _optional = optional
    }
    
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.E == E {
        if let element = _optional {
            observer.on(.next(element))
        }
        observer.on(.completed)
        return Disposables.create()
    }
}
