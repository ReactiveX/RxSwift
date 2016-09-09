//
//  DistinctUntilChanged.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DistinctUntilChangedSink<O: ObserverType, Key>: Sink<O>, ObserverType {
    typealias E = O.E
    
    private let _parent: DistinctUntilChanged<E, Key>
    private var _currentKey: Key? = nil
    
    init(parent: DistinctUntilChanged<E, Key>, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
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
                
                forwardOn(event)
            }
            catch let error {
                forwardOn(.error(error))
                dispose()
            }
        case .error, .completed:
            forwardOn(event)
            dispose()
        }
    }
}

class DistinctUntilChanged<Element, Key>: Producer<Element> {
    typealias KeySelector = (Element) throws -> Key
    typealias EqualityComparer = (Key, Key) throws -> Bool
    
    fileprivate let _source: Observable<Element>
    fileprivate let _selector: KeySelector
    fileprivate let _comparer: EqualityComparer
    
    init(source: Observable<Element>, selector: @escaping KeySelector, comparer: @escaping EqualityComparer) {
        _source = source
        _selector = selector
        _comparer = comparer
    }
    
    override func run<O: ObserverType>(_ observer: O) -> Disposable where O.E == Element {
        let sink = DistinctUntilChangedSink(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}
