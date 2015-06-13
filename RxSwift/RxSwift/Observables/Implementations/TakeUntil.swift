//
//  TakeUntil.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeUntilSinkOther<ElementType, Other, O: ObserverType where O.Element == ElementType> : ObserverType {
    typealias Parent = TakeUntilSink<ElementType, Other, O>
    typealias Element = Other
    
    let parent: Parent
    
    let singleAssignmentDisposable = SingleAssignmentDisposable()
    
    var disposable: Disposable {
        get {
            return abstractMethod()
        }
        set(value) {
            singleAssignmentDisposable.disposable = value
        }
    }
    
    init(parent: Parent) {
        self.parent = parent
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            parent.lock.performLocked {
                trySendCompleted(parent.observer)
                parent.dispose()
            }
        case .Error(let e):
            parent.lock.performLocked {
                trySendError(parent.observer, e)
                parent.dispose()
            }
        case .Completed:
            parent.lock.performLocked { () -> Void in
                parent.open = true
                singleAssignmentDisposable.dispose()
            }
        }
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}

class TakeUntilSink<ElementType, Other, O: ObserverType where O.Element == ElementType> : Sink<O>, ObserverType {
    typealias Element = ElementType
    typealias Parent = TakeUntil<Element, Other>
    
    let parent: Parent
 
    let lock = NSRecursiveLock()
    
    var open = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            if open {
                trySend(observer, event)
            }
            else {
                lock.performLocked {
                    trySend(observer, event)
                }
            }
            break
        case .Error:
            lock.performLocked {
                trySend(observer, event)
                self.dispose()
            }
            break
        case .Completed:
            lock.performLocked {
                trySend(observer, event)
                self.dispose()
            }
            break
        }
    }
    
    func run() -> Disposable {
        let otherObserver = TakeUntilSinkOther(parent: self)
        let otherSubscription = parent.other.subscribeSafe(otherObserver)
        otherObserver.disposable = otherSubscription
        let sourceSubscription = parent.source.subscribeSafe(self)
        
        return CompositeDisposable(sourceSubscription, otherSubscription)
    }
}

class TakeUntil<Element, Other>: Producer<Element> {
    
    let source: Observable<Element>
    let other: Observable<Other>
    
    init(source: Observable<Element>, other: Observable<Other>) {
        self.source = source
        self.other = other
    }
    
    override func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeUntilSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}