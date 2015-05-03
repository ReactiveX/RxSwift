//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Switch_<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = Observable<ElementType>
    typealias SwitchState = (
        subscription: SingleAssignmentDisposable,
        innerSubscription: SerialDisposable,
        stopped: Bool,
        latest: Int,
        hasLatest: Bool
    )
    
    let parent: Switch<ElementType>
    
    var lock = NSRecursiveLock()
    var switchState: SwitchState
    
    init(parent: Switch<ElementType>, observer: ObserverOf<ElementType>, cancel: Disposable) {
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
        let subscription = self.parent.sources.subscribe(self)
        let switchState = self.switchState
        switchState.subscription.setDisposable(subscription)
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
            self.switchState.innerSubscription.setDisposable(d)
               
            let observer = SwitchIter(parent: self, id: latest, _self: d)
            let disposable = observable.value.subscribe(observer)
            d.setDisposable(disposable)
        case .Error(let error):
            self.lock.performLocked {
                self.observer.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            self.lock.performLocked {
                self.switchState.stopped = true
                
                self.switchState.subscription.dispose()
                
                if !self.switchState.hasLatest {
                    self.observer.on(.Completed)
                    self.dispose()
                }
            }
        }
    }
}

class SwitchIter<ElementType> : ObserverType {
    typealias Element = ElementType
    
    let parent: Switch_<Element>
    let id: Int
    let _self: Disposable
    
    init(parent: Switch_<Element>, id: Int, _self: Disposable) {
        self.parent = parent
        self.id = id
        self._self = _self
    }
    
    func on(event: Event<ElementType>) {
        return parent.lock.calculateLocked { state in
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
                observer.on(event)
            case .Error:
                observer.on(event)
                self.parent.dispose()
            case .Completed:
                parent.switchState.hasLatest = false
                if switchState.stopped {
                    observer.on(event)
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Switch_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}