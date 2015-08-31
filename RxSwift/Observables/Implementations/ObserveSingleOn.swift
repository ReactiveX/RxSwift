//
//  ObserveSingleOn.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let ObserveSingleOnMoreThenOneElement = "Observed sequence was expected to have more then one element, and `observeSingleOn` operator works on sequences with at most one element."

// This class is used to forward sequence of AT MOST ONE observed element to
// another schedule.
//
// In case sequence contains more then one element, it will fire an exception.

class ObserveSingleOnObserver<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = ObserveSingleOn<Element>
    
    let parent: Parent
   
    var lastElement: Event<Element>? = nil
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
 
    func on(event: Event<Element>) {
        var elementToForward: Event<Element>?
        var stopEventToForward: Event<Element>?
        
        _ = self.parent.scheduler
        
        switch event {
        case .Next:
            if self.lastElement != nil {
                rxFatalError(ObserveSingleOnMoreThenOneElement)
            }
            
            self.lastElement = event
        case .Error:
            if self.lastElement != nil {
                rxFatalError(ObserveSingleOnMoreThenOneElement)
            }
            stopEventToForward = event
        case .Completed:
            elementToForward = self.lastElement
            stopEventToForward = event
        }
        
        if let stopEventToForward = stopEventToForward {
            self.parent.scheduler.schedule(()) { (_) in
                if let elementToForward = elementToForward {
                    self.observer?.on(elementToForward)
                }
                
                self.observer?.on(stopEventToForward)
                
                self.dispose()
                
                return NopDisposable.instance
            }
        }
    }

    func run() -> Disposable {
        return self.parent.source.subscribeSafe(self)
    }
}

class ObserveSingleOn<Element> : Producer<Element> {
    let scheduler: ImmediateScheduler
    let source: Observable<Element>
    
    init(source: Observable<Element>, scheduler: ImmediateScheduler) {
        self.source = source
        self.scheduler = scheduler
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ObserveSingleOnObserver(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}