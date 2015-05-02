//
//  AsObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AsObservableSink_<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = ElementType
    
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        self.observer.on(event)
        
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = AsObservableSink_(observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribe(sink)
    }
}