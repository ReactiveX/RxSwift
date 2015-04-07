//
//  Switch.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Switch_<ElementType> : Sink<ElementType>, ObserverClassType {
    typealias Element = Observable<ElementType>
    typealias SwitchState = (
        subscription: SingleAssignmentDisposable,
        innerSubscription: SerialDisposable,
        stopped: Bool,
        latest: Int,
        hasLatest: Bool
    )
    
    let parent: Switch<ElementType>
    
    var lock = Lock()
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
    
    func run() -> Result<Disposable> {
        return self.parent.sources.subscribeSafe(ObserverOf(self)) >== { subscription in
            let switchState = self.switchState
            switchState.subscription.setDisposable(subscription)
            return success(CompositeDisposable(switchState.subscription, switchState.innerSubscription))
        }
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let observable):
            let latest: Int = self.lock.calculateLocked {
                self.switchState.hasLatest = true
                self.switchState.latest = self.switchState.latest + 1
                return self.switchState.latest
            }
            
            let d = SingleAssignmentDisposable()
            self.switchState.innerSubscription.setDisposable(d)
               
            let observer = ObserverOf(SwitchIter(parent: self, id: latest, _self: d))
            return observable.value.subscribeSafe(observer) >== { disposable in
                d.setDisposable(disposable)
                return SuccessResult
            }
        case .Error(let error):
            let result = self.lock.calculateLocked {
                return self.state.observer.on(.Error(error))
            }
            self.dispose()
            return result
        case .Completed:
            return self.lock.calculateLocked {
                self.switchState.stopped = true
                
                self.switchState.subscription.dispose()
                
                var result = SuccessResult
                if !self.switchState.hasLatest {
                    result = self.state.observer.on(.Completed)
                    self.dispose()
                }
                
                return result
            }
        }
    }
}

class SwitchIter<ElementType> : ObserverClassType {
    typealias Element = ElementType
    
    let parent: Switch_<Element>
    let id: Int
    let _self: Disposable
    
    init(parent: Switch_<Element>, id: Int, _self: Disposable) {
        self.parent = parent
        self.id = id
        self._self = _self
    }
    
    func on(event: Event<ElementType>) -> Result<Void> {
        return parent.lock.calculateLocked { state in
            let switchState = self.parent.switchState
            
            switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self._self.dispose()
            }
            
            if switchState.latest != self.id {
                return success(state)
            }
           
            let observer = self.parent.state.observer
            
            switch event {
            case .Next:
                return observer.on(event)
            case .Error:
                let result = observer.on(event)
                self.parent.dispose()
                return result
            case .Completed:
                parent.switchState.hasLatest = false
                if switchState.stopped {
                    let result = observer.on(event)
                    self.parent.dispose()
                    return result
                }
                else {
                    return SuccessResult
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Switch_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}