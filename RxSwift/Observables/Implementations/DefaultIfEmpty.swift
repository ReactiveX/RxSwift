//
//  DefaultIfEmpty.swift
//  Rx
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DefaultIfEmptySink<SourceType, O: ObserverType>: Sink<O>, ObserverType where O.E == SourceType {
    private let _defaultValue: SourceType
    private var isEmpty = true
    
    init(defaultValue: SourceType, observer: O, cancel: Cancelable) {
        _defaultValue = defaultValue
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<SourceType>) {
        switch event {
        case .next(_):
            isEmpty = false
            forwardOn(event)
        case .error(_):
            forwardOn(event)
            dispose()
        case .completed:
            if isEmpty {
                forwardOn(.next(_defaultValue))
            }
            forwardOn(.completed)
            dispose()
        }
    }
}

class DefaultIfEmpty<SourceType>: Producer<SourceType> {
    private let _source: Observable<SourceType>
    private let _defautValue: SourceType
    
    init(source: Observable<SourceType>, defautValue: SourceType) {
        _source = source
        _defautValue = defautValue
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == SourceType {
        let sink = DefaultIfEmptySink(defaultValue: _defautValue, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
