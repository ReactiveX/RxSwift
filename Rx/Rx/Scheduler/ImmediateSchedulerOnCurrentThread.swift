//
//  ImmediateSchedulerOnCurrentThread.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public struct ImmediateSchedulerOnCurrentThread : ImmediateScheduler {
    public func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable> {
        return action(state) >>> { (DefaultDisposable()) }
    }
}