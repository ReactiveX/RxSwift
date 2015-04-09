//
//  Do.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Do_<ElementType> : Sink<ElementType>, ObserverClassType, Disposable {
    typealias Element = ElementType
    typealias DoType = Do<Element>
    
    let parent: DoType
    
    init(parent: DoType, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        return (parent.eventHandler(event) >>! { error in
            // catch clause
            return self.state.observer.on(Event.Error(error)) >>> { self.dispose() }
        }) >== { _ in
            return self.state.observer.on(event) >>> {
                if event.isStopEvent {
                    self.dispose()
                }
                return SuccessResult
            }
        }
    }
}

class Do<Element> : Producer<Element> {
    typealias EventHandler = Event<Element> -> Result<Void>
    
    let source: Observable<Element>
    let eventHandler: EventHandler
    
    init(source: Observable<Element>, eventHandler: EventHandler) {
        self.source = source
        self.eventHandler = eventHandler
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Do_(parent: self, observer: observer, cancel: cancel)
        
        setSink(sink)
        
        return self.source.subscribeSafe(ObserverOf(sink))
    }
}