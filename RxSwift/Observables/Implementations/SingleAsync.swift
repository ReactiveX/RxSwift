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
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            
            if let predicate = _parent._predicate {
                do {
                    print("val: \(value)")
                    let forward = try predicate(value)
                    if forward && _seenValue == false {
                        forwardOn(.Next(value))
                        _seenValue = true
                    } else if forward && _seenValue {
                        forwardOn(.Error(RxError.MoreThanOneElement))
                        dispose()
                    }
                } catch (let error) {
                    forwardOn(.Error(error as ErrorType))
                    dispose()
                }
            } else if _seenValue == false {
                forwardOn(.Next(value))
                _seenValue = true
            } else {
                forwardOn(.Error(RxError.MoreThanOneElement))
                dispose()
            }
            
        case .Error:
            forwardOn(event)
            dispose()
        case .Completed:
            if (!_seenValue) {
                forwardOn(.Error(RxError.NoElements))
            } else {
                forwardOn(.Completed)
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
    
    override func run<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = SingleAsyncSink(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}