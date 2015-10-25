//
//  RetryWhen.swift
//  Rx
//
//  Created by Junior B. on 06/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class RetryTriggerSink<S: SequenceType, O: ObserverType, RetryTriggerType, Error: ErrorType where S.Generator.Element : ObservableType, S.Generator.Element.E == O.E> : ObserverType {
    typealias E = RetryTriggerType
    
    typealias Parent = RetryWhenSequenceSink<S, O, RetryTriggerType, Error>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(event: Event<E>) {
            switch event {
            case .Next:
                parent.lock.performLocked() {
                    parent.handlerSubscription.dispose()
                    parent.lastError = nil
                    parent.scheduleMoveNext()
                }
            case .Error(_):
                parent.lock.performLocked() {
                    parent.done()
                }
            case .Completed:
                parent.lock.performLocked() {
                    parent.lastError = nil
                    parent.done()
                }
            }
    }
}

class RetryWhenSequenceSink<S: SequenceType, O: ObserverType, RetryTriggerType, Error: ErrorType where S.Generator.Element : ObservableType, S.Generator.Element.E == O.E> : TailRecursiveSink<S, O> {
    typealias Element = O.E
    typealias Parent = RetryWhenSequence<S, RetryTriggerType, Error>
    
    let lock = NSRecursiveLock()
    
    let parent: Parent
    
    var lastError: ErrorType?
    let errorSubject = PublishSubject<Error>()
    let handler: Observable<RetryTriggerType>
    let handlerSubscription = SerialDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.handler = parent.notificationHandler(errorSubject.asObservable())
        super.init(observer: observer, cancel: cancel)
    }
    
    override func on(event: Event<E>) {
        guard lastError == nil else {
            return
        }
        
        switch event {
        case .Next:
            observer?.on(event)
        case .Error(let error):
            lock.performLocked() {
                self.lastError = error
                handlerSubscription.disposable = handler.subscribeSafe(RetryTriggerSink(parent: self))
                errorSubject.on(.Next(error as! Error))
            }
        case .Completed:
            observer?.on(event)
            handlerSubscription.dispose()
            dispose()
        }
    }
    
    override func done() {
        if let lastError = self.lastError {
            observer?.on(.Error(lastError))
            self.lastError = nil
        }
        else {
            observer?.on(.Completed)
        }
        self.dispose()
    }
    
    override func dispose() {
        
        super.dispose()
    }
    
    override func extract(observable: Observable<E>) -> S.Generator? {
        if let onError = observable as? RetryWhenSequence<S, RetryTriggerType, Error> {
            return onError.sources.generate()
        }
        else {
            return nil
        }
    }
    
    override func run(sources: S.Generator) -> Disposable {
        _generators.append(sources)
        
        scheduleMoveNext()
        
        return handlerSubscription
    }
}

class RetryWhenSequence<S: SequenceType, RetryTriggerType, Error: ErrorType where S.Generator.Element : ObservableType> : Producer<S.Generator.Element.E> {
    typealias Element = S.Generator.Element.E
    
    let sources: S
    let notificationHandler: Observable<Error> -> Observable<RetryTriggerType>
    
    init(sources: S, notificationHandler: Observable<Error> -> Observable<RetryTriggerType>) {
        self.sources = sources
        self.notificationHandler = notificationHandler
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = RetryWhenSequenceSink<S, O, RetryTriggerType, Error>(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run(self.sources.generate())
    }
}