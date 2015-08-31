//
//  OperationQueueScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class OperationQueueScheduler: ImmediateScheduler {
    public let operationQueue: NSOperationQueue
    
    public init(operationQueue: NSOperationQueue) {
        self.operationQueue = operationQueue
    }
    
    public func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        
        let compositeDisposable = CompositeDisposable()
        
        weak var compositeDisposableWeak = compositeDisposable
        
        let operation = NSBlockOperation {
            if compositeDisposableWeak?.disposed ?? false {
                return
            }
            
            let disposable = action(state)
            compositeDisposableWeak?.addDisposable(disposable)
        }

        self.operationQueue.addOperation(operation)
        
        compositeDisposable.addDisposable(AnonymousDisposable {
            operation.cancel()
        })

        return compositeDisposable
    }

}