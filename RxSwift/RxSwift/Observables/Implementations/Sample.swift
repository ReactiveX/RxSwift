//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SampleImpl_<ElementType, SampleType> : ObserverType {
    typealias Element = SampleType
    typealias Parent = Sample_<ElementType, SampleType>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    func on(event: Event<Element>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                if let element = parent.sampleState.element {
                    if self.parent.parent.onlyNew {
                        parent.sampleState.element = nil
                    }
                    
                    parent.observer.on(element)
                }

                if parent.sampleState.atEnd {
                    parent.observer.on(.Completed)
                    parent.dispose()
                }
            case .Error(let e):
                parent.observer.on(.Error(e))
                parent.dispose()
            case .Completed:
                if let element = parent.sampleState.element {
                    parent.sampleState.element = nil
                    parent.observer.on(element)
                }
                if parent.sampleState.atEnd {
                    parent.observer.on(.Completed)
                    parent.dispose()
                }
            }
        }
    }
}

class Sample_<ElementType, SampleType> : Sink<ElementType>, ObserverType {
    typealias Element = ElementType
    typealias Parent = Sample<ElementType, SampleType>
    typealias SampleState = (
        element: Event<ElementType>?,
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
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        sampleState.sourceSubscription.setDisposable(parent.source.subscribe(self))
        let samplerSubscription = parent.sampler.subscribe(SampleImpl_(parent: self))
        
        return CompositeDisposable(sampleState.sourceSubscription, samplerSubscription)
    }
    
    func on(event: Event<Element>) {
        self.lock.performLocked {
            switch event {
            case .Next:
                self.sampleState.element = event
            case .Error:
                self.observer.on(event)
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Sample_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}