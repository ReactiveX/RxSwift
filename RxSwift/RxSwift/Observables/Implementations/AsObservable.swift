//
//  AsObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AsObservableSink_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        trySend(observer, event)
        
        switch event {
        case .Error: fallthrough
        case .Completed:
            self.dispose()
        default: break
        }
    }
    
}

class AsObservable<Element> : Producer<Element> {
 
    let source: Observable<Element>
    
    init(source: Observable<Element>) {
        self.source = source
    }
    
    func omega() -> Observable<Element> {
        return self
    }
    
    func eval() -> Observable<Element> {
        return source
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = AsObservableSink_(observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}