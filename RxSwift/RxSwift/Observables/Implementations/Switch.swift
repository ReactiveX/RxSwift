//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Switch_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = Observable<O.Element>
    typealias Parent = Switch<O.Element>
    
    typealias SwitchState = (
        subscription: SingleAssignmentDisposable,
        innerSubscription: SerialDisposable,
        stopped: Bool,
        latest: Int,
        hasLatest: Bool
    )
    
    let parent: Parent
    
    var lock = NSRecursiveLock()
    var switchState: SwitchState
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.switchState = (
                subscription: SingleAssignmentDisposable(),
                innerSubscription: SerialDisposable(),
                stopped: false,
                latest: 0,
                hasLatest: false
        )
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = self.parent.sources.subscribeSafe(self)
        let switchState = self.switchState
        switchState.subscription.disposable = subscription
        return CompositeDisposable(switchState.subscription, switchState.innerSubscription)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let observable):
            let latest: Int = self.lock.calculateLocked {
                self.switchState.hasLatest = true
                self.switchState.latest = self.switchState.latest + 1
                return self.switchState.latest
            }
            
            let d = SingleAssignmentDisposable()
            self.switchState.innerSubscription.disposable = d
               
            let observer = SwitchIter(parent: self, id: latest, _self: d)
            let disposable = observable.value.subscribeSafe(observer)
            d.disposable = disposable
        case .Error(let error):
            self.lock.performLocked {
                trySendError(observer, error)
                self.dispose()
            }
        case .Completed:
            self.lock.performLocked {
                self.switchState.stopped = true
                
                self.switchState.subscription.dispose()
                
                if !self.switchState.hasLatest {
                    trySendCompleted(observer)
                    self.dispose()
                }
            }
        }
    }
}

class SwitchIter<O: ObserverType> : ObserverType {
    typealias Element = O.Element
    typealias Parent = Switch_<O>
    
    let parent: Parent
    let id: Int
    let _self: Disposable
    
    init(parent: Parent, id: Int, _self: Disposable) {
        self.parent = parent
        self.id = id
        self._self = _self
    }
    
    func on(event: Event<Element>) {
        return parent.lock.calculateLocked {
            let switchState = self.parent.switchState
            
            switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self._self.dispose()
            }
            
            if switchState.latest != self.id {
                return
            }
           
            let observer = self.parent.observer
            
            switch event {
            case .Next:
                trySend(observer, event)
            case .Error:
                trySend(observer, event)
                self.parent.dispose()
            case .Completed:
                parent.switchState.hasLatest = false
                if switchState.stopped {
                    trySend(observer, event)
                    self.parent.dispose()
                }
            }
        }
    }
}

class Switch<Element> : Producer<Element> {
    let sources: Observable<Observable<Element>>
    
    init(sources: Observable<Observable<Element>>) {
        self.sources = sources
    }
    
    override func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Switch_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}