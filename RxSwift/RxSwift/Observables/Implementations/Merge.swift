//
//  Merge.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// sequential

class Merge_Iter<ElementType> : ObserverType {
    typealias Element = ElementType
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    let parent: Merge_<ElementType>
    let disposeKey: DisposeKey
    
    init(parent: Merge_<ElementType>, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            parent.lock.performLocked {
                self.parent.observer.on(event)
            }
        case .Error:
            parent.lock.performLocked {
                self.parent.observer.on(event)
                self.parent.dispose()
            }
        case .Completed:
            let group = parent.mergeState.group
            group.removeDisposable(disposeKey)
            
            self.parent.lock.performLocked {
                let state = parent.mergeState
                
                if state.stopped && state.group.count == 1 {
                    self.parent.observer.on(.Completed)
                    self.parent.dispose()
                }
            }
        }
    }
}

class Merge_<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = Observable<ElementType>
    typealias MergeState = (stopped: Bool, group: CompositeDisposable, sourceSubscription: SingleAssignmentDisposable)
    
    let parent: Merge<ElementType>
    
    var lock = NSRecursiveLock()
    
    var mergeState: MergeState = (
        stopped: false,
        group: CompositeDisposable(),
        sourceSubscription: SingleAssignmentDisposable()
    )
    
    init(parent: Merge<ElementType>, observer: ObserverOf<ElementType>, cancel: Disposable) {
        self.parent = parent
        
        let state = self.mergeState
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let state = self.mergeState
        
        state.group.addDisposable(state.sourceSubscription)
        
        let disposable = self.parent.sources.subscribe(self)
        state.sourceSubscription.setDisposable(disposable)
        
        return state.group
    }
    
    func on(event: Event<Observable<ElementType>>) {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            
            let innerSubscription = SingleAssignmentDisposable()
            let maybeKey = mergeState.group.addDisposable(innerSubscription)
            
            if let key = maybeKey {
                let observer = Merge_Iter(parent: self, disposeKey: key)
                let disposable = value.subscribe(observer)
                innerSubscription.setDisposable(disposable)
            }
        case .Error(let error):
            lock.performLocked {
                self.observer.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            lock.performLocked {
                let mergeState = self.mergeState
                
                let group = mergeState.group
                
                self.mergeState.stopped = true
                
                if group.count == 1 {
                    self.observer.on(.Completed)
                    self.dispose()
                }
                else {
                    mergeState.sourceSubscription.dispose()
                }
            }
        }
    }
}

// concurrent

class Merge_ConcurrentIter<ElementType> : ObserverType {
    typealias Element = ElementType
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    let parent: Merge_Concurrent<ElementType>
    let disposeKey: DisposeKey
    
    init(parent: Merge_Concurrent<ElementType>, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next:
            parent.lock.performLocked {
                self.parent.observer.on(event)
            }
        case .Error:
            parent.lock.performLocked {
                self.parent.observer.on(event)
                self.parent.dispose()
            }
        case .Completed:
            let mergeState = parent.mergeState
            mergeState.group.removeDisposable(disposeKey)
            parent.lock.performLocked {
                if mergeState.queue.value.count > 0 {
                    let s = mergeState.queue.value.dequeue()
                    self.parent.subscribe(s, group: mergeState.group)
                }
                else {
                    parent.mergeState.activeCount = mergeState.activeCount - 1
                    
                    if mergeState.stopped && mergeState.activeCount == 0 {
                        self.parent.observer.on(.Completed)
                        self.parent.dispose()
                    }
                }
            }
        }
    }
}

class Merge_Concurrent<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = Observable<ElementType>
    typealias QueueType = Queue<Observable<ElementType>>
    
    typealias MergeState = (
        stopped: Bool,
        queue: MutatingBox<QueueType>,
        sourceSubscription: SingleAssignmentDisposable,
        group: CompositeDisposable,
        activeCount: Int
    )
    
    let parent: Merge<ElementType>
    
    var lock = NSRecursiveLock()
    var mergeState: MergeState = (
        stopped: false,
        queue: MutatingBox(Queue(capacity: 2)),
        sourceSubscription: SingleAssignmentDisposable(),
        group: CompositeDisposable(),
        activeCount: 0
    )
    
    init(parent: Merge<ElementType>, observer: ObserverOf<ElementType>, cancel: Disposable) {
        self.parent = parent
        
        let state = self.mergeState

        _ = state.group.addDisposable(state.sourceSubscription)
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Disposable {
        let state = self.mergeState

        state.group.addDisposable(state.sourceSubscription)
        
        let disposable = self.parent.sources.subscribe(self)
        state.sourceSubscription.setDisposable(disposable)
        return state.group
    }
    
    func subscribe(innerSource: Observable<ElementType>, group: CompositeDisposable) {
        let subscription = SingleAssignmentDisposable()
        
        let key = group.addDisposable(subscription)
        
        if let key = key {
            let observer = Merge_ConcurrentIter(parent: self, disposeKey: key)
            
            let disposable = innerSource.subscribe(observer)
            subscription.setDisposable(disposable)
        }
    }
    
    func on(event: Event<Observable<ElementType>>) {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            
            let subscribe = lock.calculateLocked { () -> Bool in
                let mergeState = self.mergeState
                if mergeState.activeCount < self.parent.maxConcurrent {
                    self.mergeState.activeCount += 1
                    return true
                }
                else {
                    mergeState.queue.value.enqueue(value)
                    return false
                }
            }
            
            if subscribe {
                self.subscribe(value, group: mergeState.group)
            }
        case .Error(let error):
            lock.performLocked {
                self.observer.on(.Error(error))
                self.dispose()
            }
        case .Completed:
            lock.performLocked {
                let mergeState = self.mergeState
                let group = mergeState.group
                
                if mergeState.activeCount == 0 {
                    self.observer.on(.Completed)
                    self.dispose()
                }
                else {
                    mergeState.sourceSubscription.dispose()
                }
                    
                self.mergeState.stopped = true
            }
        }
    }
}

class Merge<Element> : Producer<Element> {
    let sources: Observable<Observable<Element>>
    let maxConcurrent: Int
    
    init(sources: Observable<Observable<Element>>, maxConcurrent: Int) {
        self.sources = sources
        self.maxConcurrent = maxConcurrent
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if maxConcurrent > 0 {
            let sink = Merge_Concurrent(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
        else {
            let sink = Merge_(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return sink.run()
        }
    }
}