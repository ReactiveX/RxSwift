//
//  DistinctUntilChanged.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DistinctUntilChangedSink<O: ObserverType, Key>: Sink<O>, ObserverType {
    typealias E = O.E
    
    let parent: DistinctUntilChanged<E, Key>
    var currentKey: Key? = nil
    
    init(parent: DistinctUntilChanged<E, Key>, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        let observer = super.observer
        
        switch event {
        case .Next(let value):
            do {
                let key = try self.parent.selector(value)
                var areEqual = false
                if let currentKey = self.currentKey {
                    areEqual = try self.parent.comparer(currentKey, key)
                }
                
                if areEqual {
                    return
                }
                
                self.currentKey = key
                
                observer?.on(event)
            }
            catch let error {
                observer?.on(.Error(error))
                self.dispose()
            }
        case .Error: fallthrough
        case .Completed:
            observer?.on(event)
            self.dispose()
        }
    }
}

class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) throws -> Key
    typealias EqualityComparer = (Key, Key) throws -> Bool
    
    let source: Observable<Element>
    let selector: KeySelector
    let comparer: EqualityComparer
    
    init(source: Observable<Element>, selector: KeySelector, comparer: EqualityComparer) {
        self.source = source
        self.selector = selector
        self.comparer = comparer
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DistinctUntilChangedSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}