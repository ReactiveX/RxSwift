//
//  Scan.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ScanSink<ElementType, Accumulate, O: ObserverType where O.E == Accumulate> : Sink<O>, ObserverType {
    typealias Parent = Scan<ElementType, Accumulate>
    typealias E = ElementType
    
    private let _parent: Parent
    private var _accumulate: Accumulate
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        _accumulate = parent._seed
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<ElementType>) {
        switch event {
        case .Next(let element):
            do {
                _accumulate = try _parent._accumulator(_accumulate, element)
                observer?.on(.Next(_accumulate))
            }
            catch let error {
                observer?.on(.Error(error))
                dispose()
            }
        case .Error(let error):
            observer?.on(.Error(error))
            dispose()
        case .Completed:
            observer?.on(.Completed)
            dispose()
        }
    }
    
}

class Scan<Element, Accumulate>: Producer<Accumulate> {
    typealias Accumulator = (Accumulate, Element) throws -> Accumulate
    
    private let _source: Observable<Element>
    private let _seed: Accumulate
    private let _accumulator: Accumulator
    
    init(source: Observable<Element>, seed: Accumulate, accumulator: Accumulator) {
        _source = source
        _seed = seed
        _accumulator = accumulator
    }
    
    override func run<O : ObserverType where O.E == Accumulate>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ScanSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return _source.subscribe(sink)
    }
}