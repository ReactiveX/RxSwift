//
//  DistinctUntilChanged.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DistinctUntilChanged_<ElementType, Key>: Sink<ElementType>, ObserverClassType {
    typealias Element = ElementType
    
    let parent: DistinctUntilChanged<ElementType, Key>
    var currentKey: Key? = nil
    
    init(parent: DistinctUntilChanged<ElementType, Key>, observer: ObserverOf<ElementType>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        let observer = super.state.observer
        
        switch event {
        case .Next(let value):
            let keyResult = self.parent.selector(value.value)
                
            let areEqualResult = keyResult >== { key -> Result<Bool> in
                if let currentKey = self.currentKey {
                    return self.parent.comparer(currentKey, key)
                }
                else {
                    return success(false)
                }
            }
            
            return (areEqualResult >== { areEqual in
                if areEqual {
                    return SuccessResult
                }
                
                self.currentKey = *keyResult
                
                return observer.on(event)
            }) >>! { error in
                let result = observer.on(.Error(error))
                self.dispose()
                return result
            }
        case .Error: fallthrough
        case .Completed:
            let result = observer.on(event)
            self.dispose()
            return result
        }
    }
}

class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) -> Result<Key>
    typealias EqualityComparer = (Key, Key) -> Result<Bool>
    
    let source: Observable<Element>
    let selector: KeySelector
    let comparer: EqualityComparer
    
    init(source: Observable<Element>, selector: KeySelector, comparer: EqualityComparer) {
        self.source = source
        self.selector = selector
        self.comparer = comparer
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        let sink = DistinctUntilChanged_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(ObserverOf(sink))
    }
}