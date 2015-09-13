//
//  Buffer.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/13/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class BufferTimeCount<Element, S: SchedulerType> : Producer<[Element]> {
    let timeSpan: S.TimeInterval
    let count: Int
    let scheduler: S
    let source: Observable<Element>
    
    init(source: Observable<Element>, timeSpan: S.TimeInterval, count: Int, scheduler: S) {
        self.source = source
        self.timeSpan = timeSpan
        self.count = count
        self.scheduler = scheduler
    }
    
    override func run<O : ObserverType where O.E == [Element]>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = BufferTimeCountSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}

class BufferTimeCountSink<S: SchedulerType, Element, O: ObserverType where O.E == [Element]> : Sink<O>, ObserverType {
    typealias Parent = BufferTimeCount<Element, S>
    typealias E = Element
    
    let parent: Parent
    
    let lock = NSRecursiveLock()
    
    // state
    let timerD = SerialDisposable()
    var buffer = [Element]()
    var windowID = 0
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
 
    func run() -> Disposable {
        createTimer(self.windowID)
        return StableCompositeDisposable.create(timerD, self.parent.source.subscribeSafe(self))
    }
    
    func startNewWindowAndSendCurrentOne() {
        self.windowID = self.windowID &+ 1
        let windowID = self.windowID
        
        let buffer = self.buffer
        self.buffer = []
        self.observer?.on(.Next(buffer))
        
        createTimer(windowID)
    }
    
    func on(event: Event<E>) {
        self.lock.performLocked {
            switch event {
            case .Next(let element):
                buffer.append(element)
                
                if buffer.count == parent.count {
                    startNewWindowAndSendCurrentOne()
                }
                
            case .Error(let error):
                self.buffer = []
                self.observer?.on(.Error(error))
                self.dispose()
            case .Completed:
                self.observer?.on(.Next(self.buffer))
                self.observer?.on(.Completed)
                self.dispose()
            }
        }
    }
    
    func createTimer(windowID: Int) {
        if timerD.disposed {
            return
        }
        
        if self.windowID != windowID {
            return
        }
        
        timerD.disposable = parent.scheduler.scheduleRelative(windowID, dueTime: self.parent.timeSpan) { previousWindowID in
            self.lock.performLocked {
                if previousWindowID != self.windowID {
                    return
                }
             
                self.startNewWindowAndSendCurrentOne()
            }
            
            return NopDisposable.instance
        }
    }
}