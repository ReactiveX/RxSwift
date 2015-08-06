//
//  ImmediateScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/31/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


public protocol ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}

public func scheduleRecursively<State>(scheduler: ImmediateScheduler, state: State,
    action: (state: State, recurse: (State) -> Void) -> Void) -> Disposable {
    let recursiveScheduler = RecursiveImmediateSchedulerOf(action: action, scheduler: scheduler)
    
    recursiveScheduler.schedule(state)
    
    return recursiveScheduler
}