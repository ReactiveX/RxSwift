//
//  ConcurrentDispatchQueueScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. You can also pass a serial dispatch queue, it shouldn't cause any problems.

This scheduler is suitable when some work needs to be performed in background.
*/
public class ConcurrentDispatchQueueScheduler: SchedulerType {
    public typealias Time = Date
    
    private let _queue : DispatchQueue
    
    public var now : Date {
        return Date()
    }
    
    // leeway for scheduling timers
    private var _leeway: Int64 = 0
    
    /**
    Constructs new `ConcurrentDispatchQueueScheduler` that wraps `queue`.
    
    - parameter queue: Target dispatch queue.
    */
    public init(queue: DispatchQueue) {
        _queue = queue
    }
    
    /**
     Convenience init for scheduler that wraps one of the global concurrent dispatch queues.
     
     - parameter globalConcurrentQueueQOS: Target global dispatch queue, by quality of service class.
     */
    @available(iOS 8, OSX 10.10, *)
    public convenience init(globalConcurrentQueueQOS: DispatchQueue.GlobalAttributes) {
        self.init(queue: DispatchQueue.global(attributes: globalConcurrentQueueQOS))
    }
//    TODO: Not sure if we  need it now
    class func convertTimeIntervalToDispatchInterval(timeInterval: TimeInterval) -> Int64 {
        return Int64(timeInterval * Double(NSEC_PER_SEC))
    }
//    TODO: Not sure if we  need it now
    class func convertTimeIntervalToDispatchTime(timeInterval: TimeInterval) -> DispatchTime {
        return DispatchTime.now() + timeInterval
    }
    
    /**
    Schedules an action to be executed immediatelly.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public final func schedule<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        return self.scheduleInternal(state: state, action: action)
    }
    
    func scheduleInternal<StateType>(state: StateType, action: (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        
        _queue.async { 
            if cancel.disposed {
                return
            }
            
            cancel.disposable = action(state)
        }
        
        return cancel
    }
    
    /**
    Schedules an action to be executed.
    
    - parameter state: State passed to the action to be executed.
    - parameter dueTime: Relative time after which to execute the action.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public final func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> Disposable) -> Disposable {
        
        // Swift 3.0 IUO
        let timer = DispatchSource.timer(flags: DispatchSource.TimerFlags(rawValue: 0), queue: _queue)
        
        let compositeDisposable = CompositeDisposable()
        timer.scheduleOneshot(deadline: DispatchTime.now() + dueTime)
        timer.setEventHandler { 
            if compositeDisposable.disposed {
                return
            }
            _ = compositeDisposable.addDisposable(disposable: action(state))
        }
        timer.resume()
        
        _ = compositeDisposable.addDisposable(disposable: AnonymousDisposable {
            timer.cancel()
        })
        
        return compositeDisposable
    }
    
    /**
    Schedules a periodic piece of work.
    
    - parameter state: State passed to the action to be executed.
    - parameter startAfter: Period after which initial work should be run.
    - parameter period: Period for running the work periodically.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> Disposable {
        
        // Swift 3.0 IUO
        let timer = DispatchSource.timer(flags: DispatchSource.TimerFlags(rawValue: 0), queue: _queue)
        let initial = DispatchTime.now() + startAfter
        
        var timerState = state
        let validDispatchInterval = period < 0 ? 0 : period
        
        timer.scheduleRepeating(deadline: initial, interval: validDispatchInterval)
        let cancel = AnonymousDisposable {
            timer.cancel()
        }
        timer.setEventHandler { 
            if cancel.disposed {
                return
            }
            timerState = action(timerState)
        }
        timer.resume()
        
        return cancel
    }
}
