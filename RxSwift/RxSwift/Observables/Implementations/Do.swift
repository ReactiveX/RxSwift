//
//  Do.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Do_<O: ObserverType> : Sink<O>, ObserverType, Disposable {
    typealias Element = O.Element
    typealias DoType = Do<Element>
    
    let parent: DoType
    
    init(parent: DoType, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        parent.eventHandler(event).recoverWith { error in
            // catch clause
            trySendError(observer, error)
            self.dispose()
            return SuccessResult
        }.flatMap { _ -> RxResult<Void> in
            trySend(observer, event)
            if event.isStopEvent {
                self.dispose()
            }
            return SuccessResult
        }
    }
}

class Do<Element> : Producer<Element> {
    typealias EventHandler = Event<Element> -> RxResult<Void>
    
    let source: Observable<Element>
    let eventHandler: EventHandler
    
    init(source: Observable<Element>, eventHandler: EventHandler) {
        self.source = source
        self.eventHandler = eventHandler
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Do_(parent: self, observer: observer, cancel: cancel)
        
        setSink(sink)
        
        return self.source.subscribeSafe(sink)
    }
}