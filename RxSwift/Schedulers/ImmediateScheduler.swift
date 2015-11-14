//
//  ImmediateScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 10/17/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Represents an object that schedules units of work to run immediately on the current thread.
*/
private class ImmediateScheduler : ImmediateSchedulerType {

    private let _asyncLock = AsyncLock<AnonymousInvocable>()

    /**
    Schedules an action to be executed immediatelly.

    In case `schedule` is called recursively from inside of `action` callback, scheduled `action` will be enqueued
    and executed after current `action`. (`AsyncLock` behavior)

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        let disposable = SingleAssignmentDisposable()
        _asyncLock.invoke(AnonymousInvocable {
            if disposable.disposed {
                return
            }
            disposable.disposable = action(state)
        })

        return disposable
    }
}