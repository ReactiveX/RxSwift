//
//  RefCount.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RefCount_<Element> : Sink<Element>, ObserverClassType {
    let parent: RefCount<Element>
    typealias ParentState = RefCount<Element>.State
    
    init(parent: RefCount<Element>, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let subscriptionResult: Result<Disposable> = self.parent.source.subscribeSafe(ObserverOf(self))
        
        if let subscriptionResultError = subscriptionResult.error {
            return .Error(subscriptionResultError)
        }
        
        let connectResult: Result<Void> = subscriptionResult >>> {
            let state = self.parent.state
            
            return self.parent.lock.calculateLocked {
                if state.count == 0 {
                    return self.parent.source.connect() >== { disposable in
                        self.parent.state.count = 1
                        self.parent.state.connectableSubscription = disposable
                        return SuccessResult
                    }
                }
                else {
                    self.parent.state.count = state.count + 1
                    return SuccessResult
                }
            }
        }
        
        if let connectResultError = connectResult.error {
            // cleanup registration
            (*subscriptionResult).dispose()
            return .Error(connectResultError)
        }
        
        return success(AnonymousDisposable {
            self.parent.lock.performLocked {
                let state = self.parent.state
                if state.count == 1 {
                    state.connectableSubscription!.dispose()
                    self.parent.state.count = 0
                    self.parent.state.connectableSubscription = nil
                }
                else if state.count > 1 {
                    self.parent.state.count = state.count - 1
                }
                else {
                    rxFatalError("Something went wrong with RefCount disposing mechanism")
                }
            }
        })
    }

    func on(event: Event<Element>) -> Result<Void> {
        let observer = state.observer
        
        switch event {
        case .Next: return observer.on(event)
        case .Error: fallthrough
        case .Completed:
            let result = observer.on(event)
            self.dispose()
            return result
        }
    }
}

class RefCount<Element>: Producer<Element> {
    typealias State = (count: Int, connectableSubscription: Disposable?)
    
    var lock = Lock()
    
    var state: State = (
        count: 0,
        connectableSubscription: nil
    )
    
    let source: ConnectableObservableType<Element>
    
    init(source: ConnectableObservableType<Element>) {
        self.source = source
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = RefCount_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}