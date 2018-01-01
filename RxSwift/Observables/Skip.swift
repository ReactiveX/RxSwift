//
//  Skip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Bypasses a specified number of elements in an observable sequence and then returns the remaining elements.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter count: The number of elements to skip before returning the remaining elements.
     - returns: An observable sequence that contains the elements that occur after the specified index in the input sequence.
     */
    public func skip(_ count: Int)
        -> Observable<E> {
        return SkipCount(source: asObservable(), count: count)
    }
}

extension ObservableType {

    /**
     Skips elements for the specified duration from the start of the observable source sequence, using the specified scheduler to run timers.

     - seealso: [skip operator on reactivex.io](http://reactivex.io/documentation/operators/skip.html)

     - parameter duration: Duration for skipping elements from the start of the sequence.
     - parameter scheduler: Scheduler to run the timer on.
     - returns: An observable sequence with the elements skipped during the specified duration from the start of the source sequence.
     */
    public func skip(_ duration: RxTimeInterval, scheduler: SchedulerType)
        -> Observable<E> {
        return SkipTime(source: self.asObservable(), duration: duration, scheduler: scheduler)
    }
}

// count version

final fileprivate class SkipCount<Element>: Producer<Element> {
    let source: Observable<Element>
    let count: Int
    
    init(source: Observable<Element>, count: Int) {
        self.source = source
        self.count = count
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        var remaining = 0
        let subscription = source.subscribe { event in
            switch event {
            case .next(let value):

                if remaining <= 0 {
                    sink.forwardOn(.next(value))
                }
                else {
                    remaining -= 1
                }
            case .error:
                sink.forwardOn(event)
                sink.dispose()
            case .completed:
                sink.forwardOn(event)
                sink.dispose()
            }
        }

        return (sink: sink, subscription: subscription)
    }
}

// time version

final fileprivate class SkipTimeSink<ElementType> : Sink<ElementType> {
    typealias Parent = SkipTime<ElementType>
    typealias Element = ElementType

    let parent: Parent
    
    // state
    var open = false
    
    init(parent: Parent, observer: @escaping (Event<ElementType>) -> (), cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<Element>) {
    }
    
    func tick() {
        open = true
    }
    
    func run() -> Disposable {
        let disposeTimer = parent.scheduler.scheduleRelative((), dueTime: self.parent.duration) { _ in 
            self.tick()
            return Disposables.create()
        }
        
        let disposeSubscription = parent.source.subscribe { event in
            switch event {
            case .next(let value):
                if self.open {
                    self.forwardOn(.next(value))
                }
            case .error:
                self.forwardOn(event)
                self.dispose()
            case .completed:
                self.forwardOn(event)
                self.dispose()
            }
        }
        
        return Disposables.create(disposeTimer, disposeSubscription)
    }
}

final fileprivate class SkipTime<Element>: Producer<Element> {
    let source: Observable<Element>
    let duration: RxTimeInterval
    let scheduler: SchedulerType
    
    init(source: Observable<Element>, duration: RxTimeInterval, scheduler: SchedulerType) {
        self.source = source
        self.scheduler = scheduler
        self.duration = duration
    }
    
    override func run(_ observer: @escaping (Event<Element>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = SkipTimeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
