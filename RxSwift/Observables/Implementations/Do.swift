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
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        do {
            try _parent._eventHandler(event)
            observer?.on(event)
            if event.isStopEvent {
                dispose()
            }
        }
        catch let error {
            observer?.on(.Error(error))
            dispose()
        }
    }
}

class Do<Element> : Producer<Element> {
    typealias EventHandler = Event<Element> throws -> Void
    
    private let _source: Observable<Element>
    private let _eventHandler: EventHandler
    
    init(source: Observable<Element>, eventHandler: EventHandler) {
        _source = source
        _eventHandler = eventHandler
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DoSink(parent: self, observer: observer, cancel: cancel)
        
        setSink(sink)
        
        return _source.subscribe(sink)
    }
}