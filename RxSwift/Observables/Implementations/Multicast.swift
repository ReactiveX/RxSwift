//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class MulticastSink<S: SubjectType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.E
    typealias ResultType = Element
    typealias MutlicastType = Multicast<S, O.E>
    
    private let _parent: MutlicastType
    
    init(parent: MutlicastType, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        do {
            let subject = try _parent._subjectSelector()
            let connectable = ConnectableObservableAdapter(source: _parent._source, subject: subject)
            
            let observable = try _parent._selector(connectable)
            
            let subscription = observable.subscribe(self)
            let connection = connectable.connect()
                
            return BinaryDisposable(subscription, connection)
        }
        catch let e {
            forwardOn(.error(e))
            dispose()
            return NopDisposable.instance
        }
    }
    
    func on(_ event: Event<ResultType>) {
        forwardOn(event)
        switch event {
            case .next: break
            case .error, .completed:
                dispose()
        }
    }
}

class Multicast<S: SubjectType, R>: Producer<R> {
    typealias SubjectSelectorType = () throws -> S
    typealias SelectorType = (Observable<S.E>) throws -> Observable<R>
    
    private let _source: Observable<S.SubjectObserverType.E>
    private let _subjectSelector: SubjectSelectorType
    private let _selector: SelectorType
    
    init(source: Observable<S.SubjectObserverType.E>, subjectSelector: SubjectSelectorType, selector: SelectorType) {
        _source = source
        _subjectSelector = subjectSelector
        _selector = selector
    }
    
    override func run<O: ObserverType where O.E == R>(_ observer: O) -> Disposable {
        let sink = MulticastSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}
