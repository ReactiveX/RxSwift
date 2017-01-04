//
//  DefaultIfEmpty.swift
//  RxSwift
//
//  Created by sergdort on 23/12/2016.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

final class DefaultIfEmptySink<SourceType, O: ObserverType>: Sink<O>, ObserverType where O.E == SourceType {
    private let _default: SourceType
    private var isEmpty = true
    
    init(default: SourceType, observer: O, cancel: Cancelable) {
        _default = `default`
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
                forwardOn(.next(_default))
            }
            forwardOn(.completed)
            dispose()
        }
    }
}

final class DefaultIfEmpty<SourceType>: Producer<SourceType> {
    private let _source: Observable<SourceType>
    private let _default: SourceType
    
    init(source: Observable<SourceType>, `default`: SourceType) {
        _source = source
        _default = `default`
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == SourceType {
        let sink = DefaultIfEmptySink(default: _default, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
