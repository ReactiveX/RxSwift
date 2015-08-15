//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class MulticastSink<SourceType, IntermediateType, O: ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias ResultType = Element
    typealias MutlicastType = Multicast<SourceType, IntermediateType, ResultType>
    
    typealias IntermediateObservable = ConnectableObservableType<IntermediateType>
    typealias ResultObservable = Observable<ResultType>
    
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

class Multicast<SourceType, IntermediateType, ResultType>: Producer<ResultType> {
    typealias SubjectSelectorType = () throws -> SubjectType<SourceType, IntermediateType>
    typealias SelectorType = (Observable<IntermediateType>) throws -> Observable<ResultType>
    
    let source: Observable<SourceType>
    let subjectSelector: SubjectSelectorType
    let selector: SelectorType
    
    init(source: Observable<SourceType>, subjectSelector: SubjectSelectorType, selector: SelectorType) {
        self.source = source
        self.subjectSelector = subjectSelector
        self.selector = selector
    }
    
    override func run<O: ObserverType where O.Element == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = MulticastSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}