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
    
    private var _elements = [ElementType]()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            _elements.append(value)
            if _elements.count > self._parent._count {
                _elements.removeFirst()
            }
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            if self._elements.count > 0 {
            self._elements.forEach { element in
                observer?.on(.Next(element))
                }
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
        _source = source
        _count = count
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeLastSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribe(sink)
    }
}