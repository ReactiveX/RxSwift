//
//  RefCount.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RefCountSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = RefCount<Element>
    
    let parent: Parent
    
    init(parent: RefCount<Element>, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let subscription = self.parent.source.subscribeSafe(self)
        
        self.parent.lock.performLocked {
            if parent.count == 0 {
                parent.count = 1
                parent.connectableSubscription = self.parent.source.connect()
            }
            else {
                parent.count = parent.count + 1
            }
        }
        
        return AnonymousDisposable {
            subscription.dispose()
            self.parent.lock.performLocked {
                if self.parent.count == 1 {
                    self.parent.connectableSubscription!.dispose()
                    self.parent.count = 0
                    self.parent.connectableSubscription = nil
                }
                else if self.parent.count > 1 {
                    self.parent.count = self.parent.count - 1
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
            observer?.on(event)
        case .Error: fallthrough
        case .Completed:
            observer?.on(event)
            self.dispose()
        }
    }
}

class RefCount<Element>: Producer<Element> {
    var lock = NSRecursiveLock()
    
    // state
    var count = 0
    var connectableSubscription = nil as Disposable?
    
    let source: ConnectableObservableType<Element>
    
    init(source: ConnectableObservableType<Element>) {
        self.source = source
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RefCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}