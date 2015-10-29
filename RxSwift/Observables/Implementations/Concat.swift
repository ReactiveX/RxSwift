//
//  Concat.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


class ConcatSink<S: SequenceType, O: ObserverType where S.Generator.Element : ObservableConvertibleType, S.Generator.Element.E == O.E> : TailRecursiveSink<S, O> {
    typealias Element = O.E
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    override func on(event: Event<Element>){
        switch event {
        case .Next:
            observer?.on(event)
        case .Error:
            observer?.on(event)
            dispose()
        case .Completed:
            scheduleMoveNext()
        }
    }
    
    override func extract(observable: Observable<E>) -> S.Generator? {
        if let source = observable as? Concat<S> {
            return source._sources.generate()
        }
        else {
            return nil
        }
    }
}

class Concat<S: SequenceType where S.Generator.Element : ObservableConvertibleType> : Producer<S.Generator.Element.E> {
    typealias Element = S.Generator.Element.E
    
    private let _sources: S
    
    init(sources: S) {
        _sources = sources
    }
    
    override func run<O: ObserverType where O.E == Element>
        (observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ConcatSink<S, O>(observer: observer, cancel: cancel)
        setSink(sink)
        
        return sink.run(_sources.generate())
    }
}