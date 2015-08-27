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
    typealias E = O.E
    typealias Parent = CatchSink<O>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(event: Event<E>) {
        parent.observer?.on(event)
        
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
    typealias E = O.E
    typealias Parent = Catch<E>
    
    let parent: Parent
    let subscription = SerialDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let d1 = SingleAssignmentDisposable()
        subscription.disposable = d1
        d1.disposable = parent.source.subscribeSafe(self)
        
        return subscription
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next:
            observer?.on(event)
        case .Completed:
            observer?.on(event)
            self.dispose()
        case .Error(let error):
            do {
                let catchSequence = try parent.handler(error)

                let observer = CatchSinkProxy(parent: self)
                
                subscription.disposable = catchSequence.subscribeSafe(observer)
            }
            catch let e {
                observer?.on(.Error(e))
                self.dispose()
            }
        }
    }
}

class Catch<Element> : Producer<Element> {
    typealias Handler = (ErrorType) throws -> Observable<Element>
    
    let source: Observable<Element>
    let handler: Handler
    
    init(source: Observable<Element>, handler: Handler) {
        self.source = source
        self.handler = handler
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

// catch to result

// O: ObserverType caused compiler crashes, so let's leave that for now
class CatchToResultSink<ElementType> : Sink<ObserverOf<RxResult<ElementType>>>, ObserverType {
    typealias E = ElementType
    typealias Parent = CatchToResult<E>
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<RxResult<E>>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        return parent.source.subscribeSafe(self)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            observer?.on(.Next(success(value)))
        case .Completed:
            observer?.on(.Completed)
            self.dispose()
        case .Error(let error):
            observer?.on(.Next(failure(error)))
            observer?.on(.Completed)
            self.dispose()
        }
    }
}

class CatchToResult<Element> : Producer <RxResult<Element>> {
    let source: Observable<Element>
    
    init(source: Observable<Element>) {
        self.source = source
    }
    
    override func run<O: ObserverType where O.E == RxResult<Element>>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchToResultSink(parent: self, observer: observer.asObserver(), cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

// catch enumerable

class CatchSequenceSink<S: SequenceType, O: ObserverType where S.Generator.Element : ObservableType, S.Generator.Element.E == O.E> : TailRecursiveSink<S, O> {
    typealias Element = O.E
    typealias Parent = CatchSequence<S>
    
    var lastError: ErrorType?
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    override func on(event: Event<Element>) {
        switch event {
        case .Next:
            observer?.on(event)
        case .Error(let error):
            self.lastError = error
            self.scheduleMoveNext()
        case .Completed:
            self.observer?.on(event)
            self.dispose()
        }
    }
    
    override func done() {
        if let lastError = self.lastError {
            observer?.on(.Error(lastError))
        }
        else {
            observer?.on(.Completed)
        }
        
        self.dispose()
    }
    
    override func extract(observable: Observable<Element>) -> S.Generator? {
        if let onError = observable as? CatchSequence<S> {
            return onError.sources.generate()
        }
        else {
            return nil
        }
    }
}

class CatchSequence<S: SequenceType where S.Generator.Element : ObservableType> : Producer<S.Generator.Element.E> {
    typealias Element = S.Generator.Element.E
    
    let sources: S
    
    init(sources: S) {
        self.sources = sources
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = CatchSequenceSink<S, O>(observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run(self.sources.generate())
    }
}