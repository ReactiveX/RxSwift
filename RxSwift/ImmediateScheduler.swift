//
//  ImmediateScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


public protocol ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable
}

extension ImmediateScheduler {
    public func scheduleRecursively<State>(state: State, action: (state: State, recurse: (State) -> Void) -> Void) -> Disposable {
        let recursiveScheduler = RecursiveImmediateSchedulerOf(action: action, scheduler: self)
        
        recursiveScheduler.schedule(state)
        
        return recursiveScheduler
    }
}
