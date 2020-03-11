//
//  Take.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Returns a specified number of contiguous elements from the start of an observable sequence.

     - seealso: [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)

     - parameter count: The number of elements to return.
     - returns: An observable sequence that contains the specified number of elements from the start of the input sequence.
     */
    public func take(_ count: Int)
        -> Observable<Element> {
        if count == 0 {
            return Observable.empty()
        }
        else {
            return TakeCount(source: self.asObservable(), count: count)
        }
    }
}

extension ObservableType {

    /**
     Takes elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.

     - seealso: [take operator on reactivex.io](http://reactivex.io/documentation/operators/take.html)

     - parameter duration: Duration for taking elements from the start of the sequence.
     - parameter scheduler: Scheduler to run the timer on.
     - returns: An observable sequence with the elements taken during the specified duration from the start of the source sequence.
     */
    public func take(_ duration: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<Element> {
        TakeTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// count version

final private class TakeCountSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Element = Observer.Element 
    typealias Parent = TakeCount<Element>
    
    private let _parent: Parent
    
    private var _remaining: Int
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        self._remaining = parent._count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            
            if self._remaining > 0 {
                self._remaining -= 1
                
                self.forwardOn(.next(value))
            
                if self._remaining == 0 {
                    self.forwardOn(.completed)
                    self.dispose()
                }
            }
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
}

final private class TakeCount<Element>: Producer<Element> {
    private let _source: Observable<Element>
    fileprivate let _count: Int
    
    init(source: Observable<Element>, count: Int) {
        if count < 0 {
            rxFatalError("count can't be negative")
        }
        self._source = source
        self._count = count
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = TakeCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

// time version

final private class TakeTimeSink<Element, Observer: ObserverType>
    : Sink<Observer>
    , LockOwnerType
    , ObserverType
    , SynchronizedOnType where Observer.Element == Element {
    typealias Parent = TakeTime<Element>

    private let _parent: Parent
    
    let _lock = RecursiveLock()
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self._parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
        self.synchronizedOn(event)
    }

    func _synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            self.forwardOn(.next(value))
        case .error:
            self.forwardOn(event)
            self.dispose()
        case .completed:
            self.forwardOn(event)
            self.dispose()
        }
    }
    
    func tick() {
        self._lock.lock(); defer { self._lock.unlock() }

        self.forwardOn(.completed)
        self.dispose()
    }
    
    func run() -> Disposable {
        let disposeTimer = self._parent._scheduler.scheduleRelative((), dueTime: self._parent._duration) { _ in
            self.tick()
            return Disposables.create()
        }
        
        let disposeSubscription = self._parent._source.subscribe(self)
        
        return Disposables.create(disposeTimer, disposeSubscription)
    }
}

final private class TakeTime<Element>: Producer<Element> {
    typealias TimeInterval = RxTimeInterval
    
    fileprivate let _source: Observable<Element>
    fileprivate let _duration: TimeInterval
    fileprivate let _scheduler: SchedulerType
    
    init(source: Observable<Element>, duration: TimeInterval, scheduler: SchedulerType) {
        self._source = source
        self._scheduler = scheduler
        self._duration = duration
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = TakeTimeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
