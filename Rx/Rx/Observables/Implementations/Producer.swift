//
//  Producer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct State<T> {
    var observer: ObserverOf<T>
    let sink: SingleAssignmentDisposable
    let subscription: SingleAssignmentDisposable
    
    init(observer: ObserverOf<T>, sink: SingleAssignmentDisposable, subscription: SingleAssignmentDisposable) {
        self.observer = observer
        self.sink = sink
        self.subscription = subscription
    }
    
    func assign(disposable: Disposable) {
        sink.setDisposable(disposable)
    }
}

class Producer<Element> : Observable<Element> {
    
    override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        return subscribeRaw(observer, enableSafeguard: true)
    }
    
    func subscribeRaw(observer: ObserverOf<Element>, enableSafeguard: Bool) -> Result<Disposable> {
        var state = State(observer: observer, sink: SingleAssignmentDisposable(), subscription: SingleAssignmentDisposable())
        
        let d = CompositeDisposable(state.sink, state.subscription)
        
        if enableSafeguard {
            state.observer = SafeObserver.create(observer, disposable: d)
        }
        
        // TODO
        /*
        if (CurrentThreadScheduler.IsScheduleRequired)
        {
            CurrentThreadScheduler.Instance.Schedule(state, Run);
        }
        */
        
        let setSink: (Disposable) -> Void = { d in state.assign(d) }
        let runResult = run(state.observer, cancel: state.subscription, setSink: setSink)
        
        return (runResult >== { disposable in
            state.subscription.setDisposable(disposable)
            return success(d)
        }) >>! { e -> Result<Disposable> in
            d.dispose()
            return .Error(e)
        }
    }
    
    func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        return abstractMethod()
    }
    
}