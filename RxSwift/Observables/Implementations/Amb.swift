//
//  Amb.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum AmbState {
    case Neither
    case Left
    case Right
}

class AmbObserver<ElementType, O: ObserverType where O.E == ElementType> : ObserverType {
    typealias Element = ElementType
    typealias Parent = AmbSink<ElementType, O>
    typealias This = AmbObserver<ElementType, O>
    typealias Sink = (This, Event<Element>) -> Void
    
    let parent: Parent
    var sink: Sink
    var cancel: Disposable
    
    init(parent: Parent, cancel: Disposable, sink: Sink) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        
        self.parent = parent
        self.sink = sink
        self.cancel = cancel
    }
    
    func on(event: Event<Element>) {
        self.sink(self, event)
        if event.isStopEvent {
            cancel.dispose()
        }
    }
    
    deinit {
#if TRACE_RESOURCES
        OSAtomicDecrement32(&resourceCount)
#endif
    }
}

class AmbSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O> {
    typealias Parent = Amb<ElementType>
    typealias AmbObserverType = AmbObserver<ElementType, O>

    let parent: Parent
    
    let lock = NSRecursiveLock()
    // state
    var choice = AmbState.Neither
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription1 = SingleAssignmentDisposable()
        let subscription2 = SingleAssignmentDisposable()
        let disposeAll = StableCompositeDisposable.create(subscription1, subscription2)
        
        let forwardEvent = { (o: AmbObserverType, event: Event<ElementType>) -> Void in
            self.observer?.on(event)
        }
        
        let decide = { (o: AmbObserverType, event: Event<ElementType>, me: AmbState, otherSubscription: Disposable) in
            self.lock.performLocked {
                if self.choice == .Neither {
                    self.choice = me
                    o.sink = forwardEvent
                    o.cancel = disposeAll
                    otherSubscription.dispose()
                }
                
                if self.choice == me {
                    self.observer?.on(event)
                    if event.isStopEvent {
                        self.dispose()
                    }
                }
            }
        }
        
        let sink1 = AmbObserver(parent: self, cancel: subscription1) { o, e in
            decide(o, e, .Left, subscription2)
        }
        
        let sink2 = AmbObserver(parent: self, cancel: subscription1) { o, e in
            decide(o, e, .Right, subscription1)
        }
        
        subscription1.disposable = self.parent.left.subscribeSafe(sink1)
        subscription2.disposable = self.parent.right.subscribeSafe(sink2)
        
        return disposeAll
    }
}

class Amb<Element>: Producer<Element> {
    let left: Observable<Element>
    let right: Observable<Element>
    
    init(left: Observable<Element>, right: Observable<Element>) {
        self.left = left
        self.right = right
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = AmbSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}