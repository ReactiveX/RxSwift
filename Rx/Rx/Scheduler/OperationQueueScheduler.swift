//
//  OperationQueueScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class OperationQueueScheduler: ImmediateScheduler {
    private let operationQueue: NSOperationQueue
    
    public init(operationQueue: NSOperationQueue) {
        self.operationQueue = operationQueue
    }
    
    public func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        let operation = NSBlockOperation {
            ensureScheduledSuccessfully(action(state))
        }
        self.operationQueue.addOperation(operation)
            
        return success(AnonymousDisposable {
            operation.cancel()
        })
    }
}