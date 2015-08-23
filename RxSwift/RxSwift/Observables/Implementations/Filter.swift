//
//  Filter.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class FilterSink<O : ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.E
    
    typealias Parent = Filter<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
            case .Next(let value):
                do {
                    let satisfies = try self.parent.predicate(value)
                    if satisfies {
                        observer?.on(.Next(value))
                    }
                }
                catch let e {
                    observer?.on(.Error(e))
                    self.dispose()
                }
            case .Completed: fallthrough
            case .Error:
                observer?.on(event)
                self.dispose()
        }
    }
}

class Filter<Element> : Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    let source: Observable<Element>
    let predicate: Predicate
    
    init(source: Observable<Element>, predicate: Predicate) {
        self.source = source
        self.predicate = predicate
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = FilterSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}