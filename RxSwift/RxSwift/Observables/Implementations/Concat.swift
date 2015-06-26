//
//  Concat.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ConcatSinkImplementation<Element> : ConcatSink<Element> {
    override init(observer: Observer<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
 
    override func on(event: Event<Element>) {
        switch event {
        case .Next(let next):
            trySend(observer, event)
        case .Error:
            trySend(observer, event)
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
    
    override func run<O: ObserverType where O.Element == Element>
        (observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ConcatSinkImplementation(observer: Observer<Element>.normalize(observer), cancel: cancel)
        setSink(sink)
        
        return sink.run(GeneratorOf(sources.generate()))
    }
}