//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SampleImpl_<O: ObserverType, ElementType, SampleType where O.Element == ElementType> : Observer<SampleType> {
    typealias Parent = Sample_<O, SampleType>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    override func on(event: Event<Element>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                if let element = parent.sampleState.element {
                    if self.parent.parent.onlyNew {
                        parent.sampleState.element = nil
                    }
                    
                    trySend(parent.observer, element)
                }

                if parent.sampleState.atEnd {
                    trySendCompleted(parent.observer)
                    parent.dispose()
                }
            case .Error(let e):
                trySendError(parent.observer, e)
                parent.dispose()
            case .Completed:
                if let element = parent.sampleState.element {
                    parent.sampleState.element = nil
                    trySend(parent.observer, element)
                }
                if parent.sampleState.atEnd {
                    trySendCompleted(parent.observer)
                    parent.dispose()
                }
            }
        }
    }
}

class Sample_<O: ObserverType, SampleType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = Sample<Element, SampleType>
    typealias SampleState = (
        element: Event<Element>?,
        atEnd: Bool,
        sourceSubscription: SingleAssignmentDisposable
    )
    
    let parent: Parent

    var lock = NSRecursiveLock()
    
    var sampleState: SampleState = (
        element: nil,
        atEnd: false,
        sourceSubscription: SingleAssignmentDisposable()
    )
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        sampleState.sourceSubscription.disposable = parent.source.subscribeSafe(self)
        let samplerSubscription = parent.sampler.subscribeSafe(SampleImpl_(parent: self))
        
        return CompositeDisposable(sampleState.sourceSubscription, samplerSubscription)
    }
    
    func on(event: Event<Element>) {
        self.lock.performLocked {
            switch event {
            case .Next:
                self.sampleState.element = event
            case .Error:
                trySend(observer, event)
                self.dispose()
            case .Completed:
                self.sampleState.atEnd = true
                self.sampleState.sourceSubscription.dispose()
            }
        }
    }
    
}

class Sample<Element, SampleType> : Producer<Element> {
    let source: Observable<Element>
    let sampler: Observable<SampleType>
    let onlyNew: Bool

    init(source: Observable<Element>, sampler: Observable<SampleType>, onlyNew: Bool) {
        self.source = source
        self.sampler = sampler
        self.onlyNew = onlyNew
    }
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Sample_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}