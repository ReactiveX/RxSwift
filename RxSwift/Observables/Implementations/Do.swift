//
//  Do.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DoSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = Do<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        do {
            try parent.eventHandler(event)
            observer?.on(event)
            if event.isStopEvent {
                self.dispose()
            }
        }
        catch let error {
            observer?.on(.Error(error))
            self.dispose()
        }
    }
}

class Do<Element> : Producer<Element> {
    typealias EventHandler = Event<Element> throws -> Void
    
    let source: Observable<Element>
    let eventHandler: EventHandler
    
    init(source: Observable<Element>, eventHandler: EventHandler) {
        self.source = source
        self.eventHandler = eventHandler
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DoSink(parent: self, observer: observer, cancel: cancel)
        
        setSink(sink)
        
        return self.source.subscribeSafe(sink)
    }
}