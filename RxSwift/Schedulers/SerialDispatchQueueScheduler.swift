//
//  SerialDispatchQueueScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure 
that even if concurrent dispatch queue is passed, it's transformed into a serial one.

It is extremely important that this scheduler is serial, because
certain operator perform optimizations that rely on that property.

Because there is no way of detecting is passed dispatch queue serial or
concurrent, for every queue that is being passed, worst case (concurrent)
will be assumed, and internal serial proxy dispatch queue will be created.

This scheduler can also be used with internal serial queue alone.

In case some customization need to be made on it before usage,
internal serial queue can be customized using `serialQueueConfiguration`
callback.
*/
public class SerialDispatchQueueScheduler: SchedulerType {
    public typealias TimeInterval = Foundation.TimeInterval
    public typealias Time = Date
    
    private let _serialQueue : DispatchQueue

    /**
    - returns: Current time.
    */
    public var now : Date {
        return Date()
    }
    
    // leeway for scheduling timers
    private var _leeway: Int64 = 0
    
    init(serialQueue: DispatchQueue) {
        _serialQueue = serialQueue
    }

    /**
    Constructs new `SerialDispatchQueueScheduler` with internal serial queue named `internalSerialQueueName`.
    
    Additional dispatch queue properties can be set after dispatch queue is created using `serialQueueConfiguration`.
    
    - parameter internalSerialQueueName: Name of internal serial dispatch queue.
    - parameter serialQueueConfiguration: Additional configuration of internal serial dispatch queue.
    */
    public convenience init(internalSerialQueueName: String, serialQueueConfiguration: ((DispatchQueue) -> Void)? = nil) {
        // Swift 3.0 IUO
        let queue = DispatchQueue(label: internalSerialQueueName, attributes: DispatchQueueAttributes.serial)
        serialQueueConfiguration?(queue)
        self.init(serialQueue: queue)
    }
    
    /**
    Constructs new `SerialDispatchQueueScheduler` named `internalSerialQueueName` that wraps `queue`.
    
    - parameter queue: Possibly concurrent dispatch queue used to perform work.
    - parameter internalSerialQueueName: Name of internal serial dispatch queue proxy.
    */
    public convenience init(queue: DispatchQueue, internalSerialQueueName: String) {
        // Swift 3.0 IUO
        let serialQueue = DispatchQueue(label: internalSerialQueueName,
                                        attributes: DispatchQueueAttributes.serial,
                                        target: queue)
        self.init(serialQueue: serialQueue)
    }

    /**
     Constructs new `SerialDispatchQueueScheduler` that wraps on of the global concurrent dispatch queues.
     
     - parameter globalConcurrentQueueQOS: Identifier for global dispatch queue with specified quality of service class.
     - parameter internalSerialQueueName: Custom name for internal serial dispatch queue proxy.
     */
    @available(iOS 8, OSX 10.10, *)
    public convenience init(globalConcurrentQueueQOS: DispatchQueueSchedulerQOS, internalSerialQueueName: String = "rx.global_dispatch_queue.serial") {
        let priority = globalConcurrentQueueQOS.QOSClass
        self.init(queue: DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(priority.rawValue))), internalSerialQueueName: internalSerialQueueName)
    }

    class func convertTimeIntervalToDispatchInterval(_ timeInterval: Foundation.TimeInterval) -> Int64 {
        return Int64(timeInterval * Double(NSEC_PER_SEC))
    }
    
    class func convertTimeIntervalToDispatchTime(_ timeInterval: Foundation.TimeInterval) -> DispatchTime {
        return DispatchTime.now() + Double(convertTimeIntervalToDispatchInterval(timeInterval)) / Double(NSEC_PER_SEC)
    }
    
    /**
    Schedules an action to be executed immediatelly.
    
    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public final func schedule<StateType>(_ state: StateType, action: (StateType) -> Disposable) -> Disposable {
        return self.scheduleInternal(state, action: action)
    }
    
    func scheduleInternal<StateType>(_ state: StateType, action: (StateType) -> Disposable) -> Disposable {
        let cancel = SingleAssignmentDisposable()
        
        _serialQueue.async {
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
    public final func scheduleRelative<StateType>(_ state: StateType, dueTime: Foundation.TimeInterval, action: (StateType) -> Disposable) -> Disposable {
    
        
        let dispatchInterval = MainScheduler.convertTimeIntervalToDispatchTime(dueTime)
        
        let compositeDisposable = CompositeDisposable()
        
        let timer = DispatchSource.timer(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: _serialQueue)
        timer.scheduleOneshot(deadline: dispatchInterval, leeway: DispatchTimeInterval.microseconds(0))
        
        timer.setEventHandler(handler: {
            if compositeDisposable.disposed {
                return
            }
            let _ = compositeDisposable.addDisposable(action(state))
        })
        timer.resume()
        
        let _ = compositeDisposable.addDisposable(AnonymousDisposable {
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
    public func schedulePeriodic<StateType>(_ state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> Disposable {
        
        
        let initial = MainScheduler.convertTimeIntervalToDispatchTime(startAfter)
        let dispatchInterval = MainScheduler.convertTimeIntervalToDispatchInterval(period)
        
        var timerState = state
        
        let validDispatchInterval = dispatchInterval < 0 ? 0 : UInt64(dispatchInterval)
        
        let timer = DispatchSource.timer(flags: DispatchSource.TimerFlags(rawValue: UInt(0)), queue: _serialQueue)
        timer.scheduleRepeating(deadline: initial, interval: DispatchTimeInterval.seconds(Int(validDispatchInterval)), leeway: DispatchTimeInterval.microseconds(0))
        
        let cancel = AnonymousDisposable {
            timer.cancel()
        }
        timer.setEventHandler(handler: {
            if cancel.disposed {
                return
            }
            timerState = action(timerState)
        })
        timer.resume()
        
        return cancel
    }
}
