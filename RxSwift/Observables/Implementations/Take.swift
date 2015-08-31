//
//  Take.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// count version

class TakeCountSink<ElementType, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeCount<ElementType>
    typealias E = ElementType
    
    let parent: Parent
    
    var remaining: Int
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.remaining = parent.count
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            
            if remaining > 0 {
                remaining--
                
                observer?.on(.Next(value))
            
                if remaining == 0 {
                    observer?.on(.Completed)
                    self.dispose()
                }
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

class TakeCount<Element>: Producer<Element> {
    let source: Observable<Element>
    let count: Int
    
    init(source: Observable<Element>, count: Int) {
        self.source = source
        self.count = count
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = TakeCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return source.subscribeSafe(sink)
    }
}

// time version

class TakeTimeSink<ElementType, S: Scheduler, O: ObserverType where O.E == ElementType> : Sink<O>, ObserverType {
    typealias Parent = TakeTime<ElementType, S>
    typealias E = ElementType
    
    let lock = NSRecursiveLock()
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<E>) {
        lock.performLocked {
            switch event {
            case .Next(let value):
                observer?.on(.Next(value))
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
        lock.performLocked {
            self.observer?.on(.Completed)
            self.dispose()
        }
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

class TakeTime<Element, S: Scheduler>: Producer<Element> {
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
        let sink = TakeTimeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}