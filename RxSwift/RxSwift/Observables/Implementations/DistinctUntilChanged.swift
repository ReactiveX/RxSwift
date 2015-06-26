//
//  DistinctUntilChanged.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DistinctUntilChanged_<O: ObserverType, Key>: Sink<O>, ObserverType {
    typealias Element = O.Element
    
    let parent: DistinctUntilChanged<Element, Key>
    var currentKey: Key? = nil
    
    init(parent: DistinctUntilChanged<Element, Key>, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        let observer = super.observer
        
        switch event {
        case .Next(let value):
            self.parent.selector(value.value).flatMap { key in
                var areEqual: RxResult<Bool>
                if let currentKey = self.currentKey {
                    areEqual = self.parent.comparer(currentKey, key)
                }
                else {
                    areEqual = success(false)
                }
                
                return areEqual.flatMap { areEqual in
                    if areEqual {
                        return SuccessResult
                    }
                    
                    self.currentKey = key
                    
                    trySend(observer, event)
                    return SuccessResult
                }
            }.recoverWith { error -> RxResult<Void> in
                trySendError(observer, error)
                self.dispose()
                return SuccessResult
            }
        case .Error: fallthrough
        case .Completed:
            trySend(observer, event)
            self.dispose()
        }
    }
}

class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) -> RxResult<Key>
    typealias EqualityComparer = (Key, Key) -> RxResult<Bool>
    
    let source: Observable<Element>
    let selector: KeySelector
    let comparer: EqualityComparer
    
    init(source: Observable<Element>, selector: KeySelector, comparer: EqualityComparer) {
        self.source = source
        self.selector = selector
        self.comparer = comparer
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DistinctUntilChanged_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}