//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Multicast_<SourceType, IntermediateType, ResultType>: Sink<ResultType>, ObserverClassType {
    typealias Element = ResultType
    typealias MutlicastType = Multicast<SourceType, IntermediateType, ResultType>
    
    typealias IntermediateObservable = ConnectableObservableType<IntermediateType>
    typealias ResultObservable = Observable<ResultType>
    
    let parent: MutlicastType
    
    init(parent: MutlicastType, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let connectableResult: Result<IntermediateObservable> = parent.subjectSelector() >== { subject in
            return success(ConnectableObservable(source: self.parent.source, subject: subject))
        }
        
        let observableResult: Result<ResultObservable> = connectableResult >== { connectable in
            return self.parent.selector(connectable)
        }
        
        let subscribeResult: Result<Disposable> = observableResult >== { observable in
            let observerOf = ObserverOf(self)
            return observable.subscribeSafe(observerOf)
        }
        
        let connectResult: Result<Disposable> = connectableResult >== { connectable in
            return connectable.connect()
        }
        
        let compositeResult = allSucceedOrDispose([subscribeResult, connectResult])
        
        return compositeResult >>! { e in
            return self.state.observer.on(Event.Error(e)) >>> { .Error(e) }
        }
    }
    
    func on(event: Event<ResultType>) -> Result<Void> {
        let result = self.state.observer.on(event)
        switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self.dispose()
        }
        return result
    }
}

class Multicast<SourceType, IntermediateType, ResultType>: Producer<ResultType> {
    typealias SubjectSelectorType = () -> Result<SubjectType<SourceType, IntermediateType>>
    typealias SelectorType = (Observable<IntermediateType>) -> Result<Observable<ResultType>>
    
    let source: Observable<SourceType>
    let subjectSelector: SubjectSelectorType
    let selector: SelectorType
    
    init(source: Observable<SourceType>, subjectSelector: SubjectSelectorType, selector: SelectorType) {
        self.source = source
        self.subjectSelector = subjectSelector
        self.selector = selector
    }
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
        var sink = Multicast_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}