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
    
    private let _parent: DistinctUntilChanged<E, Key>
    private var _currentKey: Key? = nil
    
    init(parent: DistinctUntilChanged<E, Key>, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        let observer = super.observer
        
        switch event {
        case .Next(let value):
            do {
                let key = try _parent._selector(value)
                var areEqual = false
                if let currentKey = _currentKey {
                    areEqual = try _parent._comparer(currentKey, key)
                }
                
                if areEqual {
                    return
                }
                
                _currentKey = key
                
                observer?.on(event)
            }
            catch let error {
                observer?.on(.Error(error))
                dispose()
            }
        case .Error, .Completed:
            observer?.on(event)
            dispose()
        }
    }
}

class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) throws -> Key
    typealias EqualityComparer = (Key, Key) throws -> Bool
    
    private let _source: Observable<Element>
    private let _selector: KeySelector
    private let _comparer: EqualityComparer
    
    init(source: Observable<Element>, selector: KeySelector, comparer: EqualityComparer) {
        _source = source
        _selector = selector
        _comparer = comparer
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = DistinctUntilChangedSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribe(sink)
    }
}