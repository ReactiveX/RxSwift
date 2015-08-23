//
//  Concat.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ConcatSinkImplementation<Element> : ConcatSink<Element> {
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
 
    override func on(event: Event<Element>) {
        switch event {
        case .Next(_):
            observer?.on(event)
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            super.on(event)
        }
    }
}

class Concat<Element> : Producer<Element> {
    let sources: [Observable<Element>]
    
    init(sources: [Observable<Element>]) {
        self.sources = sources
    }
    
    override func run<O: ObserverType where O.E == Element>
        (observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ConcatSinkImplementation(observer: observer.asObserver(), cancel: cancel)
        setSink(sink)
        
        return sink.run(AnySequence(sources.generate()))
    }
}