//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SwitchSink<S: ObservableType, O: ObserverType where S.E == O.E> : Sink<O>, ObserverType {
    typealias E = S
    typealias Parent = Switch<S>

    let subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    let innerSubscription: SerialDisposable = SerialDisposable()
    let parent: Parent
    
    var lock = NSRecursiveLock()
    
    // state
    var stopped = false
    var latest = 0
    var hasLatest = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = self.parent.sources.subscribeSafe(self)
        subscriptions.disposable = subscription
        return CompositeDisposable(subscriptions, innerSubscription)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let observable):
            let latest: Int = self.lock.calculateLocked {
                hasLatest = true
                self.latest = self.latest &+ 1
                return self.latest
            }
            
            let d = SingleAssignmentDisposable()
            innerSubscription.disposable = d
               
            let observer = SwitchSinkIter(parent: self, id: latest, _self: d)
            let disposable = observable.subscribeSafe(observer)
            d.disposable = disposable
        case .Error(let error):
            self.lock.performLocked {
                observer?.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            self.lock.performLocked {
                self.stopped = true
                
                self.subscriptions.dispose()
                
                if !self.hasLatest {
                    observer?.on(.Completed)
                    self.dispose()
                }
            }
        }
    }
}

class SwitchSinkIter<S: ObservableType, O: ObserverType where S.E == O.E> : ObserverType {
    typealias E = O.E
    typealias Parent = SwitchSink<S, O>
    
    let parent: Parent
    let id: Int
    let _self: Disposable
    
    init(parent: Parent, id: Int, _self: Disposable) {
        self.parent = parent
        self.id = id
        self._self = _self
    }
    
    func on(event: Event<E>) {
        return parent.lock.calculateLocked {
            
            switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self._self.dispose()
            }
            
            if parent.latest != self.id {
                return
            }
           
            let observer = self.parent.observer
            
            switch event {
            case .Next:
                observer?.on(event)
            case .Error:
                observer?.on(event)
                self.parent.dispose()
            case .Completed:
                parent.hasLatest = false
                if parent.stopped {
                    observer?.on(event)
                    self.parent.dispose()
                }
            }
        }
    }
}

class Switch<S: ObservableType> : Producer<S.E> {
    let sources: Observable<S>
    
    init(sources: Observable<S>) {
        self.sources = sources
    }
    
    override func run<O : ObserverType where O.E == S.E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SwitchSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}