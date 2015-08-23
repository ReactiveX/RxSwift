//
//  Merge.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// sequential

class MergeSinkIter<S: ObservableType, O: ObserverType where O.E == S.E> : ObserverType {
    typealias E = O.E
    typealias DisposeKey = Bag<Disposable>.KeyType
    typealias Parent = MergeSink<S, O>
    
    let parent: Parent
    let disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                parent.observer?.on(event)
            case .Error:
                parent.observer?.on(event)
                parent.dispose()
            case .Completed:
                parent.group.removeDisposable(disposeKey)
                
                if parent.stopped && parent.group.count == 1 {
                    parent.observer?.on(.Completed)
                    parent.dispose()
                }
            }
        }
    }
}

class MergeSink<S: ObservableType, O: ObserverType where O.E == S.E> : Sink<O>, ObserverType {
    typealias E = S
    typealias Parent = Merge<S>
    
    let parent: Parent
    
    var lock = NSRecursiveLock()
    
    // state
    var stopped = false
    
    let group = CompositeDisposable()
    let sourceSubscription = SingleAssignmentDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        group.addDisposable(sourceSubscription)
        
        let disposable = self.parent.sources.subscribeSafe(self)
        sourceSubscription.disposable = disposable
        
        return group
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            let innerSubscription = SingleAssignmentDisposable()
            let maybeKey = group.addDisposable(innerSubscription)
            
            if let key = maybeKey {
                let observer = MergeSinkIter(parent: self, disposeKey: key)
                let disposable = value.subscribeSafe(observer)
                innerSubscription.disposable = disposable
            }
        case .Error(let error):
            lock.performLocked {
                observer?.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            lock.performLocked {
                self.stopped = true
                
                if group.count == 1 {
                    observer?.on(.Completed)
                    self.dispose()
                }
                else {
                    sourceSubscription.dispose()
                }
            }
        }
    }
}

// concurrent

class MergeConcurrentSinkIter<S: ObservableType, O: ObserverType where S.E == O.E> : ObserverType {
    typealias E = O.E
    typealias DisposeKey = Bag<Disposable>.KeyType
    typealias Parent = MergeConcurrentSink<S, O>
    
    let parent: Parent
    let disposeKey: DisposeKey
    
    init(parent: Parent, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<E>) {
        parent.lock.performLocked {
            switch event {
            case .Next:
                parent.observer?.on(event)
            case .Error:
                parent.observer?.on(event)
                self.parent.dispose()
            case .Completed:
                parent.group.removeDisposable(disposeKey)
                let queue = parent.queue
                if queue.value.count > 0 {
                    let s = queue.value.dequeue()
                    self.parent.subscribe(s, group: parent.group)
                }
                else {
                    parent.activeCount = parent.activeCount - 1
                    
                    if parent.stopped && parent.activeCount == 0 {
                        parent.observer?.on(.Completed)
                        self.parent.dispose()
                    }
                }
            }
        }
    }
}

class MergeConcurrentSink<S: ObservableType, O: ObserverType where S.E == O.E> : Sink<O>, ObserverType {
    typealias E = S
    typealias Parent = Merge<S>
    typealias QueueType = Queue<S>
    
    let parent: Parent
    
    var lock = NSRecursiveLock()
    var stopped = false
    var activeCount = 0
    var queue = RxMutableBox(QueueType(capacity: 2))
    
    let sourceSubscription = SingleAssignmentDisposable()
    let group = CompositeDisposable()
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        
        group.addDisposable(sourceSubscription)
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        group.addDisposable(sourceSubscription)
        
        let disposable = self.parent.sources.subscribeSafe(self)
        sourceSubscription.disposable = disposable
        return group
    }
    
    func subscribe(innerSource: E, group: CompositeDisposable) {
        let subscription = SingleAssignmentDisposable()
        
        let key = group.addDisposable(subscription)
        
        if let key = key {
            let observer = MergeConcurrentSinkIter(parent: self, disposeKey: key)
            
            let disposable = innerSource.subscribeSafe(observer)
            subscription.disposable = disposable
        }
    }
    
    func on(event: Event<E>) {
        switch event {
        case .Next(let value):
            let subscribe = lock.calculateLocked { () -> Bool in
                if activeCount < self.parent.maxConcurrent {
                    self.activeCount += 1
                    return true
                }
                else {
                    queue.value.enqueue(value)
                    return false
                }
            }
            
            if subscribe {
                self.subscribe(value, group: group)
            }
        case .Error(let error):
            lock.performLocked {
                observer?.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            lock.performLocked {
                if activeCount == 0 {
                    observer?.on(.Completed)
                    self.dispose()
                }
                else {
                    sourceSubscription.dispose()
                }
                    
                stopped = true
            }
        }
    }
}

class Merge<S: ObservableType> : Producer<S.E> {
    let sources: Observable<S>
    let maxConcurrent: Int
    
    init(sources: Observable<S>, maxConcurrent: Int) {
        self.sources = sources
        self.maxConcurrent = maxConcurrent
    }
    
    override func run<O: ObserverType where O.E == S.E>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if maxConcurrent > 0 {
            let sink = MergeConcurrentSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
        else {
            let sink = MergeSink(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
    }
}