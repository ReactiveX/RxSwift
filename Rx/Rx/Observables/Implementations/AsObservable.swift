//
//  AsObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AsObservableSink_<ElementType> : ObserverClassType, Disposable {
    typealias Element = ElementType
    
    let sink: Sink<Element>
 
    func dispose() {
        sink.dispose()
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        return self.sink.state.observer.on(event)
    }
    
    init(observer: ObserverOf<Element>, cancel: Disposable) {
        self.sink = Sink(observer: observer, cancel: cancel)
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = AsObservableSink_(observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(ObserverOf(sink))
    }
}