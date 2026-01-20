//
//  VirtualTimeScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// Base class for virtual time schedulers using a priority queue for scheduled items.
open class VirtualTimeScheduler<Converter: VirtualTimeConverterType>:
    SchedulerType
{
    public typealias VirtualTime = Converter.VirtualTimeUnit
    public typealias VirtualTimeInterval = Converter.VirtualTimeIntervalUnit

    private var running: Bool

    private var currentClock: VirtualTime

    private var schedulerQueue: PriorityQueue<VirtualSchedulerItem<VirtualTime>>
    private var converter: Converter

    private var nextId = 0

    private let thread: Thread

    /// - returns: Current time.
    public var now: RxTime {
        converter.convertFromVirtualTime(clock)
    }

    /// - returns: Scheduler's absolute time clock value.
    public var clock: VirtualTime {
        currentClock
    }

    /// Creates a new virtual time scheduler.
    ///
    /// - parameter initialClock: Initial value for the clock.
    public init(initialClock: VirtualTime, converter: Converter) {
        currentClock = initialClock
        running = false
        self.converter = converter
        thread = Thread.current
        schedulerQueue = PriorityQueue(hasHigherPriority: {
            switch converter.compareVirtualTime($0.time, $1.time) {
            case .lessThan:
                true
            case .equal:
                $0.id < $1.id
            case .greaterThan:
                false
            }
        }, isEqual: { $0 === $1 })
        #if TRACE_RESOURCES
        _ = Resources.incrementTotal()
        #endif
    }

    /**
     Schedules an action to be executed immediately.

     - parameter state: State passed to the action to be executed.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func schedule<StateType>(_ state: StateType, action: @escaping (StateType) -> Disposable) -> Disposable {
        scheduleRelative(state, dueTime: .microseconds(0)) { a in
            action(a)
        }
    }

    /**
     Schedules an action to be executed.

     - parameter state: State passed to the action to be executed.
     - parameter dueTime: Relative time after which to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleRelative<StateType>(_ state: StateType, dueTime: RxTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        let time = now.addingDispatchInterval(dueTime)
        let absoluteTime = converter.convertToVirtualTime(time)
        let adjustedTime = adjustScheduledTime(absoluteTime)
        return scheduleAbsoluteVirtual(state, time: adjustedTime, action: action)
    }

    /**
     Schedules an action to be executed after relative time has passed.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action. If this is less or equal then `now`, `now + 1`  will be used.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleRelativeVirtual<StateType>(_ state: StateType, dueTime: VirtualTimeInterval, action: @escaping (StateType) -> Disposable) -> Disposable {
        let time = converter.offsetVirtualTime(clock, offset: dueTime)
        return scheduleAbsoluteVirtual(state, time: time, action: action)
    }

    /**
     Schedules an action to be executed at absolute virtual time.

     - parameter state: State passed to the action to be executed.
     - parameter time: Absolute time when to execute the action.
     - parameter action: Action to be executed.
     - returns: The disposable object used to cancel the scheduled action (best effort).
     */
    public func scheduleAbsoluteVirtual<StateType>(_ state: StateType, time: VirtualTime, action: @escaping (StateType) -> Disposable) -> Disposable {
        ensusreRunningOnCorrectThread()
        let compositeDisposable = CompositeDisposable()

        let item = VirtualSchedulerItem(action: {
            action(state)
        }, time: time, id: nextId)

        nextId += 1

        schedulerQueue.enqueue(item)

        _ = compositeDisposable.insert(item)

        return compositeDisposable
    }

    /// Adjusts time of scheduling before adding item to schedule queue.
    open func adjustScheduledTime(_ time: VirtualTime) -> VirtualTime {
        time
    }

    /// Starts the virtual time scheduler.
    public func start() {
        if running {
            return
        }

        ensusreRunningOnCorrectThread()
        running = true
        repeat {
            guard let next = findNext() else {
                break
            }

            if converter.compareVirtualTime(next.time, clock).greaterThan {
                currentClock = next.time
            }

            next.invoke()
            schedulerQueue.remove(next)
        } while running

        running = false
    }

    func findNext() -> VirtualSchedulerItem<VirtualTime>? {
        while let front = schedulerQueue.peek() {
            if front.isDisposed {
                schedulerQueue.remove(front)
                continue
            }

            return front
        }

        return nil
    }

    /// Advances the scheduler's clock to the specified time, running all work till that point.
    ///
    /// - parameter virtualTime: Absolute time to advance the scheduler's clock to.
    public func advanceTo(_ virtualTime: VirtualTime) {
        if running {
            fatalError("Scheduler is already running")
        }

        ensusreRunningOnCorrectThread()
        running = true
        repeat {
            guard let next = findNext() else {
                break
            }

            if converter.compareVirtualTime(next.time, virtualTime).greaterThan {
                break
            }

            if converter.compareVirtualTime(next.time, clock).greaterThan {
                currentClock = next.time
            }
            next.invoke()
            schedulerQueue.remove(next)
        } while running

        currentClock = virtualTime
        running = false
    }

    /// Advances the scheduler's clock by the specified relative time.
    public func sleep(_ virtualInterval: VirtualTimeInterval) {
        ensusreRunningOnCorrectThread()
        let sleepTo = converter.offsetVirtualTime(clock, offset: virtualInterval)
        if converter.compareVirtualTime(sleepTo, clock).lessThen {
            fatalError("Can't sleep to past.")
        }

        currentClock = sleepTo
    }

    /// Stops the virtual time scheduler.
    public func stop() {
        ensusreRunningOnCorrectThread()
        running = false
    }

    #if TRACE_RESOURCES
    deinit {
        _ = Resources.decrementTotal()
    }
    #endif

    private func ensusreRunningOnCorrectThread() {
        guard Thread.current == thread else {
            rxFatalError("Executing on the wrong thread. Please ensure all work on the same thread.")
        }
    }
}

// MARK: description

extension VirtualTimeScheduler: CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        schedulerQueue.debugDescription
    }
}

final class VirtualSchedulerItem<Time>:
    Disposable
{
    typealias Action = () -> Disposable

    let action: Action
    let time: Time
    let id: Int

    var isDisposed: Bool {
        disposable.isDisposed
    }

    var disposable = SingleAssignmentDisposable()

    init(action: @escaping Action, time: Time, id: Int) {
        self.action = action
        self.time = time
        self.id = id
    }

    func invoke() {
        disposable.setDisposable(action())
    }

    func dispose() {
        disposable.dispose()
    }
}

extension VirtualSchedulerItem:
    CustomDebugStringConvertible
{
    var debugDescription: String {
        "\(time)"
    }
}
