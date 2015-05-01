//
//  Concat.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Concat_<Element> : ConcatSink<Element> {
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
 
    override func on(event: Event<Element>) {
        switch event {
        case .Next(let next):
            observer.on(event)
        case .Error:
            observer.on(event)
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Concat_(observer: observer, cancel: cancel)
        setSink(sink)
        
        return sink.run(sources)
    }
}