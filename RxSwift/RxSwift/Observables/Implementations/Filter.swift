//
//  Filter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Where_<O : ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.Element
    
    typealias Parent = Where<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
            case .Next(let boxedValue):
                let value = boxedValue.value
                _ = self.parent.predicate(value).recoverWith { e in
                    trySendError(observer, e)
                    self.dispose()
                    return failure(e)
                }.flatMap { satisfies -> RxResult<Void> in
                    if satisfies {
                        trySend(observer, event)
                    }
                    return SuccessResult
                }
            case .Completed: fallthrough
            case .Error:
                trySend(observer, event)
                self.dispose()
        }
    }
}

class Where<Element> : Producer<Element> {
    typealias Predicate = (Element) -> RxResult<Bool>
    
    let source: Observable<Element>
    let predicate: Predicate
    
    init(source: Observable<Element>, predicate: Predicate) {
        self.source = source
        self.predicate = predicate
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Where_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}