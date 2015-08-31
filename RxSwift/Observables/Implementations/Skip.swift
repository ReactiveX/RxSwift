//
//  Skip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// count version

class SkipCountSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = SkipCount<ElementType>
    typealias Element = ElementType
    
    let parent: Parent
    
    var remaining: Int
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.remaining = parent.count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            
            if remaining <= 0 {
                observer?.on(.Next(value))
            }
            else {
                remaining--
            }
        case .Error:
            observer?.on(event)
            self.dispose()
        case .Completed:
            observer?.on(event)
            self.dispose()
        }
    }
    
}

class SkipCount<Element>: Producer<Element> {
    let source: Observable<Element>
    let count: Int
    
    init(source: Observable<Element>, count: Int) {
        self.source = source
        self.count = count
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SkipCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}

// time version

class SkipTimeSink<ElementType, S: Scheduler, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = SkipTime<ElementType, S>
    typealias Element = ElementType

    let parent: Parent
    
    let lock = NSRecursiveLock()
    var open = false
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        lock.performLocked {
            switch event {
            case .Next(let value):
                if open {
                    observer?.on(.Next(value))
                }
            case .Error:
                observer?.on(event)
                self.dispose()
            case .Completed:
                observer?.on(event)
                self.dispose()
            }
        }
    }
    
    func tick() {
        open = true
    }
    
    func run() -> Disposable {
        let disposeTimer = parent.scheduler.scheduleRelative((), dueTime: self.parent.duration) {
            self.tick()
            return NopDisposable.instance
        }
        
        let disposeSubscription = parent.source.subscribeSafe(self)
        
        return BinaryDisposable(disposeTimer, disposeSubscription)
    }
}

class SkipTime<Element, S: Scheduler>: Producer<Element> {
    typealias TimeInterval = S.TimeInterval
    
    let source: Observable<Element>
    let duration: TimeInterval
    let scheduler: S
    
    init(source: Observable<Element>, duration: TimeInterval, scheduler: S) {
        self.source = source
        self.scheduler = scheduler
        self.duration = duration
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = SkipTimeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}