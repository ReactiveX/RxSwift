//
//  Multicast.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/27/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Multicast_<SourceType, IntermediateType, ResultType>: Sink<ResultType>, ObserverType {
    typealias Element = ResultType
    typealias MutlicastType = Multicast<SourceType, IntermediateType, ResultType>
    
    typealias IntermediateObservable = ConnectableObservableType<IntermediateType>
    typealias ResultObservable = Observable<ResultType>
    
    let parent: MutlicastType
    
    init(parent: MutlicastType, observer: ObserverOf<ResultType>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return *(parent.subjectSelector() >== { subject in
            let connectable = ConnectableObservable(source: self.parent.source, subject: subject)
            
            return self.parent.selector(connectable) >== { observable in
                let subscription = observable.subscribe(self)
                let connection = connectable.connect()
                
                return success(CompositeDisposable(subscription, connection))
            }
        } >>! { e in
            self.observer.on(.Error(e))
            self.dispose()
            return success(DefaultDisposable())
        })
    }
    
    func on(event: Event<ResultType>) {
        self.observer.on(event)
        switch event {
            case .Next: break
            case .Error: fallthrough
            case .Completed: self.dispose()
        }
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
    
    override func run(observer: ObserverOf<ResultType>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        var sink = Multicast_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}