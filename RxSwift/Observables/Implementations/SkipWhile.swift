//
//  SkipWhile.swift
//  Rx
//
//  Created by Yury Korolev on 10/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

class SkipWhileSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {

    typealias Parent = SkipWhile<ElementType>
    typealias Element = ElementType

    private let _parent: Parent
    private var _running = false

    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            if !_running {
                do {
                    _running = try !_parent._predicate(value)
                } catch let e {
                    _observer?.onError(e)
                    dispose()
                    return
                }
            }

            if _running {
                _observer?.onNext(value)
            }
        case .Error, .Completed:
            _observer?.on(event)
            dispose()
        }
    }
}

class SkipWhileSinkIndexed<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {

    typealias Parent = SkipWhile<ElementType>
    typealias Element = ElementType

    private let _parent: Parent
    private var _index = 0
    private var _running = false

    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            if !_running {
                do {
                    _running = try !_parent._predicateIndexed(value, _index)
                    _index += 1
                } catch let e {
                    _observer?.onError(e)
                    dispose()
                    return
                }
            }

            if _running {
                _observer?.onNext(value)
            }
        case .Error, .Completed:
            _observer?.on(event)
            dispose()
        }
    }
}

class SkipWhile<Element>: Producer<Element> {
    typealias Predicate = (Element) throws -> Bool
    typealias PredicateIndexed = (Element, Int) throws -> Bool

    private let _source: Observable<Element>
    private let _predicate: Predicate!
    private let _predicateIndexed: PredicateIndexed!

    init(source: Observable<Element>, predicate: Predicate) {
        _source = source
        _predicate = predicate
        _predicateIndexed = nil
    }

    init(source: Observable<Element>, predicate: PredicateIndexed) {
        _source = source
        _predicate = nil
        _predicateIndexed = predicate
    }

    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = _predicate {
            let sink = SkipWhileSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribeSafe(sink)
        }
        else {
            let sink = SkipWhileSinkIndexed(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribeSafe(sink)
        }
    }
}
