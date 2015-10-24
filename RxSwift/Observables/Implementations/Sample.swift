//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SamplerSink<O: ObserverType, ElementType, SampleType where O.E == ElementType> : ObserverType {
    typealias E = SampleType
    
    typealias Parent = SampleSequenceSink<O, SampleType>
    
    private let _parent: Parent
    
    init(parent: Parent) {
        _parent = parent
    }
    
    func on(event: Event<E>) {
        _parent._lock.performLocked {
            switch event {
            case .Next:
                if let element = _parent._element {
                    if _parent._parent._onlyNew {
                        _parent._element = nil
                    }
                    
                    _parent.observer?.on(.Next(element))
                }

                if _parent._atEnd {
                    _parent.observer?.on(.Completed)
                    _parent.dispose()
                }
            case .Error(let e):
                _parent.observer?.on(.Error(e))
                _parent.dispose()
            case .Completed:
                if let element = _parent._element {
                    _parent._element = nil
                    _parent.observer?.on(.Next(element))
                }
                if _parent._atEnd {
                    _parent.observer?.on(.Completed)
                    _parent.dispose()
                }
            }
        }
    }
}

class SampleSequenceSink<O: ObserverType, SampleType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = Sample<Element, SampleType>
    
    private let _parent: Parent

    private let _lock = NSRecursiveLock()
    
    // state
    private var _element = nil as Element?
    private var _atEnd = false
    
    private let _sourceSubscription = SingleAssignmentDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        _sourceSubscription.disposable = _parent._source.subscribe(self)
        let samplerSubscription = _parent._sampler.subscribe(SamplerSink(parent: self))
        
        return CompositeDisposable(_sourceSubscription, samplerSubscription)
    }
    
    func on(event: Event<Element>) {
        _lock.performLocked {
            switch event {
            case .Next(let element):
                _element = element
            case .Error:
                observer?.on(event)
                dispose()
            case .Completed:
                _atEnd = true
                _sourceSubscription.dispose()
            }
        }
    }
    
}

class Sample<Element, SampleType> : Producer<Element> {
    private let _source: Observable<Element>
    private let _sampler: Observable<SampleType>
    private let _onlyNew: Bool

    init(source: Observable<Element>, sampler: Observable<SampleType>, onlyNew: Bool) {
        _source = source
        _sampler = sampler
        _onlyNew = onlyNew
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SampleSequenceSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}