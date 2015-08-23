//
//  TakeUntil.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeUntilSinkOther<ElementType, Other, O: ObserverType where O.E == ElementType> : ObserverType {
    typealias Parent = TakeUntilSink<ElementType, Other, O>
    typealias E = Other
    
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
    
    func on(event: Event<E>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                parent.observer?.on(.Completed)
                parent.dispose()
            case .Error(let e):
                parent.observer?.on(.Error(e))
                parent.dispose()
            case .Completed:
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

class TakeUntilSink<ElementType, Other, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias E = ElementType
    typealias Parent = TakeUntil<E, Other>
    
    let parent: Parent
 
    let lock = NSRecursiveLock()
    // state
    var open = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next:
            if open {
                observer?.on(event)
            }
            else {
                lock.performLocked {
                    observer?.on(event)
                }
            }
            break
        case .Error:
            lock.performLocked {
                observer?.on(event)
                self.dispose()
            }
            break
        case .Completed:
            lock.performLocked {
                observer?.on(event)
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
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeUntilSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}