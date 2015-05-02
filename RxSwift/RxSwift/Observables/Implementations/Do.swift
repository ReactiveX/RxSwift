//
//  Do.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Do_<ElementType> : Sink<ElementType>, ObserverType, Disposable {
    typealias Element = ElementType
    typealias DoType = Do<Element>
    
    let parent: DoType
    
    init(parent: DoType, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        parent.eventHandler(event) >>! { error in
            // catch clause
            self.observer.on(.Error(error))
            self.dispose()
            return SuccessResult
        } >== { _ -> Result<Void> in
            self.observer.on(event)
            if event.isStopEvent {
                self.dispose()
            }
            return SuccessResult
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Do_(parent: self, observer: observer, cancel: cancel)
        
        setSink(sink)
        
        return self.source.subscribe(sink)
    }
}