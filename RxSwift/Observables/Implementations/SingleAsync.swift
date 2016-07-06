//
//  SingleAsync.swift
//  Rx
//
//  Created by Junior B. on 09/11/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SingleAsyncSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = SingleAsync<ElementType>
    typealias E = ElementType
    
    private let _parent: Parent
    private var _seenValue: Bool = false
    
    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            do {
                let forward = try _parent._predicate?(value) ?? true
                if !forward {
                    return
                }
            }
            catch let error {
                forwardOn(.error(error as ErrorProtocol))
                dispose()
                return
            }

            if _seenValue == false {
                _seenValue = true
                forwardOn(.next(value))
            } else {
                forwardOn(.error(RxError.moreThanOneElement))
                dispose()
            }
            
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            if (!_seenValue) {
                forwardOn(.error(RxError.noElements))
            } else {
                forwardOn(.completed)
            }
            dispose()
        }
    }
}

class SingleAsync<Element>: Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    
    private let _source: Observable<Element>
    private let _predicate: Predicate?
    
    init(source: Observable<Element>, predicate: Predicate? = nil) {
        _source = source
        _predicate = predicate
    }
    
    override func run<O : ObserverType where O.E == Element>(_ observer: O) -> Disposable {
        let sink = SingleAsyncSink(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}
