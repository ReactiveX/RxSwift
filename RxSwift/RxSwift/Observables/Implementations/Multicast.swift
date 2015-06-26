//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Multicast_<SourceType, IntermediateType, O: ObserverType>: Sink<O>, ObserverType {
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
        return parent.subjectSelector().flatMap { subject in
            let connectable = ConnectableObservable(source: self.parent.source, subject: subject)
            
            return self.parent.selector(connectable).flatMap { observable in
                let subscription = observable.subscribeSafe(self)
                let connection = connectable.connect()
                
                return success(CompositeDisposable(subscription, connection))
            }
        }.recoverWith { e in
            trySendError(observer, e)
            self.dispose()
            return NopDisposableResult
        }.get()
    }
    
    func on(event: Event<ResultType>) {
        trySend(observer, event)
        switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self.dispose()
        }
    }
}

class Multicast<SourceType, IntermediateType, ResultType>: Producer<ResultType> {
    typealias SubjectSelectorType = () -> RxResult<SubjectType<SourceType, IntermediateType>>
    typealias SelectorType = (Observable<IntermediateType>) -> RxResult<Observable<ResultType>>
    
    let source: Observable<SourceType>
    let subjectSelector: SubjectSelectorType
    let selector: SelectorType
    
    init(source: Observable<SourceType>, subjectSelector: SubjectSelectorType, selector: SelectorType) {
        self.source = source
        self.subjectSelector = subjectSelector
        self.selector = selector
    }
    
    override func run<O: ObserverType where O.Element == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        var sink = Multicast_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}