//
//  Scan.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ScanSink<ElementType, Accumulate, O: ObserverType where O.E == Accumulate> : Sink<O>, ObserverType {
    typealias Parent = Scan<ElementType, Accumulate>
    typealias E = ElementType
    
    private let _parent: Parent
    private var _accumulate: Accumulate
    
    init(parent: Parent, observer: O) {
        _parent = parent
        _accumulate = parent._seed
        super.init(observer: observer)
    }
    
    func on(_ event: Event<ElementType>) {
        switch event {
        case .next(let element):
            do {
                _accumulate = try _parent._accumulator(_accumulate, element)
                forwardOn(.next(_accumulate))
            }
            catch let error {
                forwardOn(.error(error))
                dispose()
            }
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
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
    
    override func run<O : ObserverType where O.E == Accumulate>(_ observer: O) -> Disposable {
        let sink = ScanSink(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}
