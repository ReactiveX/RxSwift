//
//  Where.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Where_<ElementType>: Sink<ElementType>, ObserverType {
    typealias Parent = Where<Element>
    typealias Element = ElementType
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                _ = self.parent.predicate(value) >>! { e in
                    self.observer.on(.Error(e))
                    self.dispose()
                    return .Error(e)
                } >== { satisfies -> Result<Void> in
                    if satisfies {
                        self.observer.on(event)
                    }
                    return SuccessResult
                }
            case .Completed: fallthrough
            case .Error:
                observer.on(event)
                self.dispose()
        }
    }
}

class Where<Element> : Producer<Element> {
    typealias Predicate = (Element) -> Result<Bool>
    
    let source: Observable<Element>
    let predicate: Predicate
    
    init(source: Observable<Element>, predicate: Predicate) {
        self.source = source
        self.predicate = predicate
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Where_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribe(sink)
    }
}