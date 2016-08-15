//
//  Concat.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


class ConcatSink<S: Sequence, O: ObserverType where S.Iterator.Element : ObservableConvertibleType, S.Iterator.Element.E == O.E>
    : TailRecursiveSink<S, O>
    , ObserverType {
    typealias Element = O.E
    
    override init(observer: O) {
        super.init(observer: observer)
    }
    
    func on(_ event: Event<Element>){
        switch event {
        case .next:
            forwardOn(event)
        case .error:
            forwardOn(event)
            dispose()
        case .completed:
            schedule(.moveNext)
        }
    }

    override func subscribeToNext(_ source: Observable<E>) -> Disposable {
        return source.subscribe(self)
    }
    
    override func extract(_ observable: Observable<E>) -> SequenceGenerator? {
        if let source = observable as? Concat<S> {
            return (source._sources.makeIterator(), source._count)
        }
        else {
            return nil
        }
    }
}

class Concat<S: Sequence where S.Iterator.Element : ObservableConvertibleType> : Producer<S.Iterator.Element.E> {
    typealias Element = S.Iterator.Element.E
    
    private let _sources: S
    private let _count: IntMax?

    init(sources: S, count: IntMax?) {
        _sources = sources
        _count = count
    }
    
    override func run<O: ObserverType where O.E == Element>(_ observer: O) -> Disposable {
        let sink = ConcatSink<S, O>(observer: observer)
        sink.disposable = sink.run((_sources.makeIterator(), _count))
        return sink
    }
}
