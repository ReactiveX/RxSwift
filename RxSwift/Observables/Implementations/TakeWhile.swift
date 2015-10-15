//
//  TakeWhile.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TakeWhileSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType

    private let _parent: Parent

    private var _running = true

    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            if !_running {
                return
            }
            
            do {
                _running = try _parent._predicate(value)
            } catch let e {
                observer?.onError(e)
                dispose()
                return
            }
            
            if _running {
                observer?.onNext(value)
            } else {
                observer?.onComplete()
                dispose()
            }
        case .Error, .Completed:
            observer?.on(event)
            dispose()
        }
    }
    
}

class TakeWhileSinkWithIndex<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeWhile<ElementType>
    typealias Element = ElementType
    
    private let _parent: Parent
    
    private var _running = true
    private var _index = 0
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            if !_running {
                return
            }
            
            do {
                _running = try _parent._predicateWithIndex(value, _index)
                try incrementChecked(&_index)
            } catch let e {
                observer?.onError(e)
                dispose()
                return
            }
            
            if _running {
                observer?.onNext(value)
            } else {
                observer?.onComplete()
                dispose()
            }
        case .Error, .Completed:
            observer?.on(event)
            dispose()
        }
    }
    
}

class TakeWhile<Element>: Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    typealias PredicateWithIndex = (Element, Int) throws -> Bool

    private let _source: Observable<Element>
    private let _predicate: Predicate!
    private let _predicateWithIndex: PredicateWithIndex!

    init(source: Observable<Element>, predicate: Predicate) {
        _source = source
        _predicate = predicate
        _predicateWithIndex = nil
    }
    
    init(source: Observable<Element>, predicate: PredicateWithIndex) {
        _source = source
        _predicate = nil
        _predicateWithIndex = predicate
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = _predicate {
            let sink = TakeWhileSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribeSafe(sink)
        } else {
            let sink = TakeWhileSinkWithIndex(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribeSafe(sink)
        }
    }
}