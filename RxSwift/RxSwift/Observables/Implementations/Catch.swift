//
//  Catch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// catch with callback

class CatchSinkProxy<O: ObserverType> : ObserverType {
    typealias Element = O.Element
    typealias Parent = CatchSink<O>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(event: Event<Element>) {
        trySend(parent.observer, event)
        
        switch event {
        case .Next:
            break
        case .Error:
            parent.dispose()
        case .Completed:
            parent.dispose()
        }
    }
}

class CatchSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = Catch<Element>
    
    let parent: Parent
    let subscription = SerialDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let disposableSubscription = parent.source.subscribeSafe(self)
        subscription.disposable = disposableSubscription
        
        return subscription
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            trySend(observer, event)
        case .Completed:
            trySend(observer, event)
            self.dispose()
        case .Error(let error):
            parent.handler(error).recoverWith { error2 in
                trySendError(observer, error2)
                self.dispose()
                return failure(error2)
            }.flatMap { catchObservable -> RxResult<Void> in
                let d = SingleAssignmentDisposable()
                subscription.disposable = d
                
                let observer = CatchSinkProxy(parent: self)
                
                let subscription2 = catchObservable.subscribeSafe(observer)
                d.disposable = subscription2
                return SuccessResult
            }
        }
    }
}

class Catch<Element> : Producer<Element> {
    typealias Handler = (ErrorType) -> RxResult<Observable<Element>>
    
    let source: Observable<Element>
    let handler: Handler
    
    init(source: Observable<Element>, handler: Handler) {
        self.source = source
        self.handler = handler
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

// catch to result

// O: ObserverType caused compiler crashes, so let's leave that for now
class CatchToResultSink<ElementType> : Sink<Observer<RxResult<ElementType>>>, ObserverType {
    typealias Element = ElementType
    typealias Parent = CatchToResult<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: Observer<RxResult<Element>>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return parent.source.subscribeSafe(self)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            trySendNext(observer, success(value))
        case .Completed:
            trySendCompleted(observer)
            self.dispose()
        case .Error(let error):
            trySendNext(observer, failure(error))
            trySendCompleted(observer)
            self.dispose()
        }
    }
}

class CatchToResult<Element> : Producer <RxResult<Element>> {
    let source: Observable<Element>
    
    init(source: Observable<Element>) {
        self.source = source
    }
    
    override func run<O: ObserverType where O.Element == RxResult<Element>>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchToResultSink(parent: self, observer: Observer<RxResult<Element>>.normalize(observer), cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

// catch enumerable

class CatchSequenceSink<O: ObserverType> : TailRecursiveSink<O> {
    typealias Element = O.Element
    typealias Parent = CatchSequence<Element>
    
    var lastError: ErrorType?
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    override func on(event: Event<Element>) {
        switch event {
        case .Next:
            trySend(observer, event)
        case .Error(let error):
            self.lastError = error
            self.scheduleMoveNext()
        case .Completed:
            trySend(self.observer, event)
            self.dispose()
        }
    }
    
    override func done() {
        if let lastError = self.lastError {
            trySendError(observer, lastError)
        }
        else {
            trySendCompleted(observer)
        }
        
        self.dispose()
    }
    
    override func extract(observable: Observable<Element>) -> GeneratorOf<Observable<O.Element>>? {
        if let catch = observable as? CatchSequence<Element> {
            return catch.sources.generate()
        }
        else {
            return nil
        }
    }
}

class CatchSequence<Element> : Producer<Element> {
    let sources: SequenceOf<Observable<Element>>
    
    init(sources: SequenceOf<Observable<Element>>) {
        self.sources = sources
    }
    
    override func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchSequenceSink(observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run(self.sources.generate())
    }
}