//
//  Buffer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Projects each element of an observable sequence into a buffer that's sent out when either it's full or a given amount of time has elapsed, using the specified scheduler to run timers.

     A useful real-world analogy of this overload is the behavior of a ferry leaving the dock when all seats are taken, or at the scheduled time of departure, whichever event occurs first.

     - seealso: [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)

     - parameter timeSpan: Maximum time length of a buffer.
     - parameter count: Maximum element count of a buffer.
     - parameter scheduler: Scheduler to run buffering timers on.
     - returns: An observable sequence of buffers.
     */
    public func buffer(timeSpan: RxTimeInterval, count: Int, scheduler: SchedulerType)
        -> Observable<[Element]> {
        BufferTimeCount(source: self.asObservable(), timeSpan: timeSpan, count: count, scheduler: scheduler)
    }
}

final private class BufferTimeCount<Element>: Producer<[Element]> {
    
    fileprivate let timeSpan: RxTimeInterval
    fileprivate let count: Int
    fileprivate let scheduler: SchedulerType
    fileprivate let source: Observable<Element>
    
    init(source: Observable<Element>, timeSpan: RxTimeInterval, count: Int, scheduler: SchedulerType) {
        self.source = source
        self.timeSpan = timeSpan
        self.count = count
        self.scheduler = scheduler
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == [Element] {
        let sink = BufferTimeCountSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final private class BufferTimeCountSink<Element, Observer: ObserverType>
    : Sink<Observer>
    , LockOwnerType
    , ObserverType
    , SynchronizedOnType where Observer.Element == [Element] {
    typealias Parent = BufferTimeCount<Element>
    
    private let parent: Parent
    
    let lock = RecursiveLock()

    private let timerD = SerialDisposable()
    private var buffer = [Element]()
    private var windowID = 0
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
 
    func run() -> Disposable {
        self.createTimer(self.windowID)
        return Disposables.create(timerD, parent.source.subscribe(self))
    }
    
    func startNewWindowAndSendCurrentOne() {
        self.windowID = self.windowID &+ 1
        let windowID = self.windowID
        
        let buffer = self.buffer
        self.buffer = []
        self.forwardOn(.next(buffer))
        
        self.createTimer(windowID)
    }
    
    func on(_ event: Event<Element>) {
        self.synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            self.buffer.append(element)
            
            if self.buffer.count == self.parent.count {
                self.startNewWindowAndSendCurrentOne()
            }
            
        case .error(let error):
            self.buffer = []
            self.forwardOn(.error(error))
            self.dispose()
        case .completed:
            self.forwardOn(.next(self.buffer))
            self.forwardOn(.completed)
            self.dispose()
        }
    }
    
    func createTimer(_ windowID: Int) {
        if self.timerD.isDisposed {
            return
        }
        
        if self.windowID != windowID {
            return
        }

        let nextTimer = SingleAssignmentDisposable()
        
        self.timerD.disposable = nextTimer

        let disposable = self.parent.scheduler.scheduleRelative(windowID, dueTime: self.parent.timeSpan) { previousWindowID in
            self.lock.performLocked {
                if previousWindowID != self.windowID {
                    return
                }
             
                self.startNewWindowAndSendCurrentOne()
            }
            
            return Disposables.create()
        }

        nextTimer.setDisposable(disposable)
    }
}

extension ObservableType {
    
    /**
     Projects each element of an observable sequence info a buffer that's sent out when the trigger Observable emits a .next event or a .complete event, if the accumulated buffer's count
     is over zero.
     
     - seealso: [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)
     
     - parameter trigger: Observable that will act as a boundary trigger between each window.
     - returns: An observable sequence of buffers.
     */
    public func buffer<TriggerElement>(trigger: Observable<TriggerElement>) -> Observable<[Element]> {
        return BufferTrigger(source: self.asObservable(), trigger: trigger)
    }
    
    /**
     Projects each element of an observable sequence info a buffer that's sent out when the trigger Observable emits a .next event or a .complete event, if the accumulated buffer's count
     is over zero.
     
     A useful real-world example of this is when you have a resource that needs to be updated depending on some asynchronous tasks and you want to accumulate all of those tasks's results
     and just PUT/PATCH the remote resource once per batch of results instead of once per result.
     
     - seealso: [buffer operator on reactivex.io](http://reactivex.io/documentation/operators/buffer.html)
     
     - parameter debounce: Amount of time to debounce the source as the boundary trigger between each window.
     - parameter scheduler: Scheduler to run debouncing on.
     - returns: An observable sequence of buffers.
     */
    public func buffer(debounce: RxTimeInterval, scheduler: SchedulerType) -> Observable<[Element]> {
        let shared = self.share()
        return shared.buffer(trigger: shared.debounce(debounce, scheduler: scheduler))
    }
}

final fileprivate class BufferTrigger<Element, TriggerElement> : Producer<[Element]> {
    fileprivate let source: Observable<Element>
    fileprivate let trigger: Observable<TriggerElement>
    
    init(source: Observable<Element>, trigger: Observable<TriggerElement>) {
        self.source = source
        self.trigger = trigger
    }
    
    override func run<Observer : ObserverType>(_ observer: Observer, cancel: Cancelable)
     -> (sink: Disposable, subscription: Disposable) where Observer.Element == [Element] {
        let sink = BufferTriggerSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class BufferTriggerSink<Element, TriggerElement, Observer: ObserverType>
    : Sink<Observer>
    , LockOwnerType
    , ObserverType
    , SynchronizedOnType where Observer.Element == [Element] {
    typealias Parent = BufferTrigger<Element, TriggerElement>

    private let parent: Parent
    
    let lock = RecursiveLock()
    
    // state
    private let serialDisposable = SerialDisposable()
    private var buffer = [Element]()
    
    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let disposable = SingleAssignmentDisposable()
        serialDisposable.disposable = disposable
        disposable.setDisposable(parent.trigger.subscribe { event in
            switch event {
            case .next:
                let window = self.buffer
                self.buffer = []
                if !window.isEmpty {
                    self.forwardOn(.next(window))
                }
                break
            case .error(let error):
                self.buffer = []
                self.forwardOn(.error(error))
                self.dispose()
                break
            case .completed:
                if !self.buffer.isEmpty {
                    self.forwardOn(.next(self.buffer))
                }
                self.forwardOn(.completed)
                self.dispose()
                break
            }
        })
        
        return Disposables.create(serialDisposable, parent.source.subscribe(self))
    }
    
    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }
    
    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next(let element):
            buffer.append(element)
        case .error(let error):
            buffer = []
            forwardOn(.error(error))
            dispose()
        case .completed:
            if buffer.count > 0 {
                forwardOn(.next(buffer))
            }
            forwardOn(.completed)
            dispose()
        }
    }
}
