//
//  Scheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (StateType) -> Result<Void>) -> Result<Disposable>
}

public protocol Scheduler: ImmediateScheduler {
    typealias TimeInterval
    typealias Time
    
    var now : Time {
        get
    }

    func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> Result<Void>) -> Result<Disposable>
}


// This is being called every time `Rx` scheduler performs action to
// check the result of the computation.
//
// The default implementation will throw an Exception if the result failed.
//
// It's probably best to make sure all of the errors have been handled before
// the computation finishes, but it's not unreasonable to change the implementation
// for release builds to silently fail (although I would not recommended).
//
// Changing default behavior is not recommended because possible data corruption
// is "usually" a lot worse then letting program to crash.
//
func ensureScheduledSuccessfully(result: Result<Void>) -> Result<Void> {
    switch result {
    case .Error(let error):
        return errorDuringScheduledAction(error);
    default: break
    }
    
    return SuccessResult
}

func errorDuringScheduledAction(error: ErrorType) -> Result<Void> {
    let exception = NSException(name: "ScheduledActionError", reason: "Error happened during scheduled action execution", userInfo: ["error": error])
    exception.raise()
    
    return SuccessResult
}
