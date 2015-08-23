//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class MulticastSink<S: SubjectType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.E
    typealias ResultType = Element
    typealias MutlicastType = Multicast<S, O.E>
    
    let parent: MutlicastType
    
    init(parent: MutlicastType, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        do {
            let subject = try parent.subjectSelector()
            let connectable = ConnectableObservable(source: self.parent.source, subject: subject)
            
            let observable = try self.parent.selector(connectable)
            
            let subscription = observable.subscribeSafe(self)
            let connection = connectable.connect()
                
            return BinaryDisposable(subscription, connection)
        }
        catch let e {
            observer?.on(.Error(e))
            self.dispose()
            return NopDisposable.instance
        }
    }
    
    func on(event: Event<ResultType>) {
        observer?.on(event)
        switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self.dispose()
        }
    }
}

class Multicast<S: SubjectType, R>: Producer<R> {
    typealias SubjectSelectorType = () throws -> S
    typealias SelectorType = (Observable<S.E>) throws -> Observable<R>
    
    let source: Observable<S.SubjectObserverType.E>
    let subjectSelector: SubjectSelectorType
    let selector: SelectorType
    
    init(source: Observable<S.SubjectObserverType.E>, subjectSelector: SubjectSelectorType, selector: SelectorType) {
        self.source = source
        self.subjectSelector = subjectSelector
        self.selector = selector
    }
    
    override func run<O: ObserverType where O.E == R>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = MulticastSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}