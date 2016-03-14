//
//  VirtualTimeScheduler.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Base class for virtual time schedulers using a priority queue for scheduled items.
*/
public class VirtualTimeScheduler<Converter: VirtualTimeConverterType>
    : SchedulerType
    , CustomDebugStringConvertible {

    public typealias VirtualTime = Converter.VirtualTimeUnit
    public typealias VirtualTimeInterval = Converter.VirtualTimeIntervalUnit

    private var _running : Bool

    private var _clock: VirtualTime

    private var _schedulerQueue : PriorityQueue<VirtualSchedulerItem<VirtualTime>>
    private var _converter: Converter

    private var _nextId = 0

    /**
    - returns: Current time.
    */
    public var now: RxTime {
        return _converter.convertFromVirtualTime(clock)
    }

    /**
    - returns: Scheduler's absolute time clock value.
    */
    public var clock: VirtualTime {
        return _clock
    }

    /**
     Creates a new virtual time scheduler.
     
     - parameter initialClock: Initial value for the clock.
    */
    public init(initialClock: VirtualTime, converter: Converter) {
        _clock = initialClock
        _running = false
        _converter = converter
        _schedulerQueue = PriorityQueue(hasHigherPriority: {
            switch converter.compareVirtualTime($0.time, $1.time) {
            case .LessThan:
                return true
            case .Equal:
                return $0.id < $1.id
            case .GreaterThan:
                return false
            }
        })
        #if TRACE_RESOURCES
            AtomicIncrement(&resourceCount)
        #endif
    }

    /**
    Schedules an action to be executed immediatelly.

    - parameter state: State passed to the action to be executed.
    - parameter action: Action to be executed.
    - returns: The disposable object used to cancel the scheduled action (best effort).
    */
    public func schedule<StateType>(state: StateType, action: StateType -> Disposable) -> Disposable {
        return self.scheduleRelative(state, dueTime: 0.0) { a in
            return action(a)
        }
    }

    /**
     Schedules an action to be executed.

     - parameter state: State passed to the action to be executed.
     - parameter dueTime: Relative time after which to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleRelative<StateType>(state: StateType, dueTime: RxTimeInterval, action: StateType -> Disposable) -> Disposable {
        let time = self.now.dateByAddingTimeInterval(dueTime)
        let absoluteTime = _converter.convertToVirtualTime(time)
        let adjustedTime = self.adjustScheduledTime(absoluteTime)
        return scheduleAbsoluteVirtual(state, time: adjustedTime, action: action)
    }

    /**
     Schedules an action to be executed after relative time has passed.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleRelativeVirtual<StateType>(state: StateType, dueTime: VirtualTimeInterval, action: StateType -> Disposable) -> Disposable {
        let time = _converter.offsetVirtualTime(time: self.clock, offset: dueTime)
        return scheduleAbsoluteVirtual(state, time: time, action: action)
    }

    /**
     Schedules an action to be executed at absolute virtual time.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleAbsoluteVirtual<StateType>(state: StateType, time: Converter.VirtualTimeUnit, action: StateType -> Disposable) -> Disposable {
        MainScheduler.ensureExecutingOnScheduler()

        let compositeDisposable = CompositeDisposable()

        let item = VirtualSchedulerItem(action: {
            let dispose = action(state)
            return dispose
        }, time: time, id: _nextId)

        _nextId += 1

        _schedulerQueue.enqueue(item)
        
        compositeDisposable.addDisposable(item)
        
        return compositeDisposable
    }

    /**
    Adjusts time of scheduling before adding item to schedule queue.
    */
    public func adjustScheduledTime(time: Converter.VirtualTimeUnit) -> Converter.VirtualTimeUnit {
        return time
    }

    /**
    Starts the virtual time scheduler.
    */
    public func start() {
        MainScheduler.ensureExecutingOnScheduler()

        if _running {
            return
        }

        _running = true
        repeat {
            guard let next = findNext() else {
                break
            }

            if _converter.compareVirtualTime(next.time, self.clock).greaterThan  {
                _clock = next.time
            }

            next.invoke()
            _schedulerQueue.remove(next)
        } while _running

        _running = false
    }

    func findNext() -> VirtualSchedulerItem<VirtualTime>? {
        while let front = _schedulerQueue.peek() {
            if front.disposed {
                _schedulerQueue.remove(front)
                continue
            }

            return front
        }

        return nil
    }

    /**
     Advances the scheduler's clock to the specified time, running all work till that point.
     
     - parameter virtualTime: Absolute time to advance the scheduler's clock to.
    */
    public func advanceTo(virtualTime: VirtualTime) {
        MainScheduler.ensureExecutingOnScheduler()

        if _running {
            fatalError("Scheduler is already running")
        }

        _running = true
        repeat {
            guard let next = findNext() else {
                break
            }

            if _converter.compareVirtualTime(next.time, virtualTime).greaterThan {
                break
            }

            if _converter.compareVirtualTime(next.time, self.clock).greaterThan  {
                _clock = next.time
            }

            next.invoke()
            _schedulerQueue.remove(next)
        } while _running

        _clock = virtualTime
        _running = false
    }

    /**
    Advances the scheduler's clock by the specified relative time.
    */
    public func sleep(virtualInterval: VirtualTimeInterval) {
        MainScheduler.ensureExecutingOnScheduler()

        let sleepTo = _converter.offsetVirtualTime(time: clock, offset: virtualInterval)
        if _converter.compareVirtualTime(sleepTo, clock).lessThen {
            fatalError("Can't sleep to past.")
        }

        _clock = sleepTo
    }

    /**
    Stops the virtual time scheduler.
    */
    public func stop() {
        MainScheduler.ensureExecutingOnScheduler()

        _running = false
    }

    #if TRACE_RESOURCES
        deinit {
            AtomicDecrement(&resourceCount)
        }
    #endif
}

// MARK: description

extension VirtualTimeScheduler {
    /**
    A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        return self._schedulerQueue.debugDescription
    }
}

class VirtualSchedulerItem<Time>
    : Disposable {
    typealias Action = () -> Disposable
    
    let action: Action
    let time: Time
    let id: Int

    var disposed: Bool {
        return disposable.disposed
    }
    
    var disposable = SingleAssignmentDisposable()
    
    init(action: Action, time: Time, id: Int) {
        self.action = action
        self.time = time
        self.id = id
    }

    func invoke() {
         self.disposable.disposable = action()
    }
    
    func dispose() {
        self.disposable.dispose()
    }
}

extension VirtualSchedulerItem
    : CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(time)"
    }
}