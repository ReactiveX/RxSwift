//
//  ConcatSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ConcatSink<Element> : TailRecursiveSink<ObserverOf<Element>> {
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    override func on(event: Event<Element>){
        switch event {
        case .Completed:
            scheduleMoveNext()
        default:
            super.on(event)
        }
    }
    
    override func extract(observable: Observable<Element>) -> AnyGenerator<Observable<Element>>? {
        if let source = observable as? Concat<Element> {
            return anyGenerator(source.sources.generate())
        }
        else {
            return nil
        }
    }
}