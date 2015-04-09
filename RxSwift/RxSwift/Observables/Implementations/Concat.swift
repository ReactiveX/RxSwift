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
 
    override func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let next):
            return observer.on(event)
        case .Error:
            let result = observer.on(event)
            dispose()
            return result
        case .Completed:
            return super.on(event)
        }
    }
}

class Concat<Element> : Producer<Element> {
    let sources: [Observable<Element>]
    
    init(sources: [Observable<Element>]) {
        self.sources = sources
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = Concat_(observer: observer, cancel: cancel)
        setSink(sink)
        
        return sink.run(sources)
    }
}