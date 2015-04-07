//
//  Merge.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// sequential

class Merge_Iter<ElementType> : ObserverClassType {
    typealias Element = ElementType
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    let parent: Merge_<ElementType>
    let disposeKey: DisposeKey
    
    init(parent: Merge_<ElementType>, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            return parent.lock.calculateLocked {
                return self.parent.observer.on(event)
            }
        case .Error:
            return parent.lock.calculateLocked {
                self.parent.dispose()

                return self.parent.observer.on(event)
            }
        case .Completed:
            let group = parent.mergeState.group
            group.removeDisposable(disposeKey)
            return parent.lock.calculateLocked {
                let state = parent.mergeState
                if state.stopped && state.group.count == 1 {
                    let result = self.parent.observer.on(.Completed)
                    self.parent.dispose()
                    return result
                }
                return SuccessResult
            }
        }
    }
}

class Merge_<ElementType> : Sink<ElementType>, ObserverClassType {
    typealias Element = Observable<ElementType>
    typealias MergeState = (stopped: Bool, group: CompositeDisposable, sourceSubscription: SingleAssignmentDisposable)
    
    let parent: Merge<ElementType>
    
    var lock = Lock()
    var mergeState: MergeState = (
        stopped: false,
        group: CompositeDisposable(),
        sourceSubscription: SingleAssignmentDisposable()
    )
    
    init(parent: Merge<ElementType>, observer: ObserverOf<ElementType>, cancel: Disposable) {
        self.parent = parent
        
        let state = self.mergeState
        
        state.group.addDisposable(state.sourceSubscription)
        super.init(observer: observer, cancel: cancel)
    }
    
    func run() -> Result<Disposable> {
        let state = self.mergeState
        
        state.group.addDisposable(state.sourceSubscription)
        
        return self.parent.sources.subscribe(ObserverOf(self)) >== { disposable in
            state.sourceSubscription.setDisposable(disposable)
            return success(state.group)
        }
    }
    
    func on(event: Event<Observable<ElementType>>) -> Result<Void> {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            
            let innerSubscription = SingleAssignmentDisposable()
            let mergeStateSnapshot = mergeState
            let maybeKey = mergeStateSnapshot.group.addDisposable(innerSubscription)
            
            if let key = maybeKey {
                let observer = ObserverOf(Merge_Iter(parent: self, disposeKey: key))
                return value.subscribeSafe(observer) >== { disposable in
                    innerSubscription.setDisposable(disposable)
                    return SuccessResult
                }
            }
            // it was already disposed
            else {
                return SuccessResult
            }
        case .Error(let error):
            return lock.calculateLocked { Void -> Result<Void> in
                let result = self.observer.on(.Error(error))
                self.dispose()
                return result
            }
        case .Completed:
            return lock.calculateLocked {
                let mergeState = self.mergeState
                
                let group = mergeState.group
                
                self.mergeState.stopped = true
                
                if group.count == 1 {
                    let result = self.observer.on(.Completed)
                    self.dispose()
                    return result
                }
                else {
                    mergeState.sourceSubscription.dispose()
                    return SuccessResult
                }
            }
        }
    }
}

// concurrent

class Merge_ConcurrentIter<ElementType> : ObserverClassType {
    typealias Element = ElementType
    typealias DisposeKey = Bag<Disposable>.KeyType
    
    let parent: Merge_Concurrent<ElementType>
    let disposeKey: DisposeKey
    
    init(parent: Merge_Concurrent<ElementType>, disposeKey: DisposeKey) {
        self.parent = parent
        self.disposeKey = disposeKey
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            return parent.lock.calculateLocked {
                return self.parent.observer.on(event)
            }
        case .Error:
            return parent.lock.calculateLocked {
                let result = self.parent.observer.on(event)
                self.parent.dispose()
                return result
            }
        case .Completed:
            let mergeState = parent.mergeState
            mergeState.group.removeDisposable(disposeKey)
            return parent.lock.calculateLocked {
                if mergeState.queue.value.count > 0 {
                    let s = mergeState.queue.value.dequeue()
                    return self.parent.subscribe(s, group: mergeState.group)
                }
                else {
                    parent.mergeState.activeCount = mergeState.activeCount - 1
                    
                    var result = SuccessResult
                    if mergeState.stopped && mergeState.activeCount == 0 {
                        result = self.parent.observer.on(.Completed)
                        self.parent.dispose()
                    }
                    
                    return result
                }
            }
        }
    }
}

class Merge_Concurrent<ElementType> : Sink<ElementType>, ObserverClassType {
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
    
    var lock = Lock()
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
    
    func run() -> Result<Disposable> {
        let state = self.mergeState

        state.group.addDisposable(state.sourceSubscription)
        
        return self.parent.sources.subscribe(ObserverOf(self)) >== { disposable in
            state.sourceSubscription.setDisposable(disposable)
            return success(state.group)
        }
    }
    
    func subscribe(innerSource: Observable<ElementType>, group: CompositeDisposable) -> Result<Void> {
        let subscription = SingleAssignmentDisposable()
        
        let key = group.addDisposable(subscription)
        
        if let key = key {
            let observer = ObserverOf(Merge_ConcurrentIter(parent: self, disposeKey: key))
            
            return innerSource.subscribeSafe(observer) >== { disposable in
                subscription.setDisposable(disposable)
                return SuccessResult
            }
        }
        else {
            return SuccessResult
        }
    }
    
    func on(event: Event<Observable<ElementType>>) -> Result<Void> {
        switch event {
        case .Next(let boxedValue):
            let value = boxedValue.value
            
            return lock.calculateLocked {
                let mergeState = self.mergeState
                if mergeState.activeCount < self.parent.maxConcurrent {
                    return self.subscribe(value, group: mergeState.group) >>> {
                        self.mergeState.activeCount += 1
                        return SuccessResult
                    }
                }
                else {
                    mergeState.queue.value.enqueue(value)
                    return SuccessResult
                }
            }
        case .Error(let error):
            return lock.calculateLocked { Void -> Result<Void> in
                let result = self.observer.on(.Error(error))
                self.dispose()
                return result
            }
        case .Completed:
            return lock.calculateLocked {
                let mergeState = self.mergeState
                let group = mergeState.group
                
                var result: Result<Void>
                
                if mergeState.activeCount == 0 {
                    result = self.observer.on(.Completed)
                    self.dispose()
                }
                else {
                    mergeState.sourceSubscription.dispose()
                    result = SuccessResult
                }
                    
                return result >>> {
                    self.mergeState.stopped = true
                    return SuccessResult
                }
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
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Result<Disposable> {
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