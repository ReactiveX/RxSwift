//
//  TakeLast.swift
//  Rx
//
//  Created by Tomi Koskinen on 25/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


class TakeLastSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeLast<ElementType>
    typealias E = ElementType
    
    private let _parent: Parent
    
    private var _elements: Queue<ElementType>
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        _elements = Queue<ElementType>(capacity: parent._count)
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            _elements.enqueue(value)
            if _elements.count > self._parent._count {
                _elements.dequeue()
            }
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            for e in _elements {
                observer?.on(.Next(e))
            }
            observer?.on(.Completed)
            dispose()
        }
    }
}

class TakeLast<Element>: Producer<Element> {
    private let _source: Observable<Element>
    private let _count: Int
    
    init(source: Observable<Element>, count: Int) {
        if count < 0 {
            rxFatalError("count can't be negative")
        }
        _source = source
        _count = count
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeLastSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribe(sink)
    }
}