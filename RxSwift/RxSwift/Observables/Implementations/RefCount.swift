//
//  RefCount.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RefCount_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    let parent: RefCount<Element>
    typealias ParentState = RefCount<Element>.State
    
    init(parent: RefCount<Element>, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = self.parent.source.subscribeSafe(self)
        
        let state = self.parent.state
        
        self.parent.lock.performLocked {
            if state.count == 0 {
                self.parent.state.count = 1
                self.parent.state.connectableSubscription = self.parent.source.connect()
            }
            else {
                self.parent.state.count = state.count + 1
            }
        }
        
        return AnonymousDisposable {
            subscription.dispose()
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
        }
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next:
            trySend(observer, event)
        case .Error: fallthrough
        case .Completed:
            trySend(observer, event)
            self.dispose()
        }
    }
}

class RefCount<Element>: Producer<Element> {
    typealias State = (
        count: Int,
        connectableSubscription: Disposable?
    )
    
    var lock = SpinLock()
    
    var state: State = (
        count: 0,
        connectableSubscription: nil
    )
    
    let source: ConnectableObservableType<Element>
    
    init(source: ConnectableObservableType<Element>) {
        self.source = source
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RefCount_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}