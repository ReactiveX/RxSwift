//
//  Scheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol Scheduler: ImmediateScheduler {
    typealias TimeInterval
    typealias Time
    
    var now : Time {
        get
    }

    func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}


// This is being called every time `Rx` scheduler performs action to
// check the result of the computation.
//
// The default implementation will throw an Exception if the result failed.
//
// It's probably best to make sure all of the errors have been handled before
// the computation finishes, but it's not unreasonable to change the implementation
// for release builds to silently fail (although I would not recommend it).
//
// Changing default behavior is not recommended because possible data corruption
// is "usually" a lot worse than letting the program crash.
//
func ensureScheduledSuccessfully(result: RxResult<Void>) -> RxResult<Void> {
    switch result {
    case .Failure(let error):
        return errorDuringScheduledAction(error);
    default: break
    }
    
    return SuccessResult
}

func getScheduledDisposable(disposable: RxResult<Disposable>) -> Disposable {
    switch disposable {
    case .Failure(let error):
        errorDuringScheduledAction(error);
        return NopDisposable.instance
    default:
        return disposable.get()
    }
}

func errorDuringScheduledAction(error: ErrorType) -> RxResult<Void> {
    let exception = NSException(name: "ScheduledActionError", reason: "Error happened during scheduled action execution", userInfo: ["error": error])
    exception.raise()
    
    return SuccessResult
}
