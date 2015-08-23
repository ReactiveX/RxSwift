//
//  Sample.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SamplerSink<O: ObserverType, ElementType, SampleType where O.E == ElementType> : Observer<SampleType> {
    typealias Parent = SampleSequenceSink<O, SampleType>
    
    let parent: Parent
    
    init(parent: Parent) {
        self.parent = parent
    }
    
    override func on(event: Event<E>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                if let element = parent.element {
                    if self.parent.parent.onlyNew {
                        parent.element = nil
                    }
                    
                    parent.observer?.on(.Next(element))
                }

                if parent.atEnd {
                    parent.observer?.on(.Completed)
                    parent.dispose()
                }
            case .Error(let e):
                parent.observer?.on(.Error(e))
                parent.dispose()
            case .Completed:
                if let element = parent.element {
                    parent.element = nil
                    parent.observer?.on(.Next(element))
                }
                if parent.atEnd {
                    parent.observer?.on(.Completed)
                    parent.dispose()
                }
            }
        }
    }
}

class SampleSequenceSink<O: ObserverType, SampleType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = Sample<Element, SampleType>
    
    let parent: Parent

    var lock = NSRecursiveLock()
    // state
    var element = nil as Element?
    var atEnd = false
    
    let sourceSubscription = SingleAssignmentDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        sourceSubscription.disposable = parent.source.subscribeSafe(self)
        let samplerSubscription = parent.sampler.subscribeSafe(SamplerSink(parent: self))
        
        return CompositeDisposable(sourceSubscription, samplerSubscription)
    }
    
    func on(event: Event<Element>) {
        self.lock.performLocked {
            switch event {
            case .Next(let element):
                self.element = element
            case .Error:
                observer?.on(event)
                self.dispose()
            case .Completed:
                atEnd = true
                sourceSubscription.dispose()
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
    
    override func run<O: ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SampleSequenceSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}