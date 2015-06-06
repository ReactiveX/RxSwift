//
//  ImmediateSchedulerOnProducerThread.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol WorkItemProtocol {
    var disposed: Bool {
        get
    }
    
    func invoke(scheduler: ImmediateScheduler) -> RxResult<Void>
}

class WorkItem<T> : WorkItemProtocol, Disposable {
    typealias Action = (/*ImmediateScheduler,*/ T) -> RxResult<Disposable>
    
    var state: T!
    var action: Action!
    
    let disposable = SingleAssignmentDisposable()
    
    var disposed: Bool {
        get {
            return disposable.disposed
        }
    }
    
    init(state: T, action: Action) {
        self.state = state
        self.action = action
    }
    
    func invoke(scheduler: ImmediateScheduler) -> RxResult<Void> {
        return action(/*scheduler,*/ state).map { chainedDisposable in
            self.disposable.setDisposable(disposable)
            return ()
        }
    }
    
    func dispose() {
        state = nil
        action = nil
        disposable.dispose()
    }
}

class TailCallOptimizationAdapter : ImmediateScheduler {
    let enqueueItem: SinkOf<WorkItemProtocol>
    
    init(enqueueItem: SinkOf<WorkItemProtocol>) {
        self.enqueueItem = enqueueItem
    }
    
    func schedule<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable> {
        let item = WorkItem(state: state, action: action)
        enqueueItem.put(item)
        return success(item)
    }
}

// Scheduler that executes work on same thread that produced the element.
// It also has tail recursion optimizations.
struct ImmediateSchedulerOnProducerThread : ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable> {
        var stop = false

        var queue = Queue<WorkItemProtocol>(capacity: 4)
        
        queue.enqueue(WorkItem(state: state, action: action))
        
        let cancel = CompositeDisposable()
        let tailCallOptimizationAdapter = TailCallOptimizationAdapter(enqueueItem: SinkOf { workItem in
            queue.enqueue(workItem)
        })
        
        while !queue.empty {
            let workItem = queue.dequeue()
            
            if workItem.disposed {
                continue
            }
            
            let invokeResult = workItem.invoke(tailCallOptimizationAdapter)
            if invokeResult.isFailure {
                return invokeResult.map {
                    NopDisposable.instance
                }
            }
        }
        
        return NopDisposableResult
    }
}