//
//  MainScheduler.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Dispatch
#if !os(Linux)
    import Foundation
#endif

/**
Abstracts work that needs to be performed on `DispatchQueue.main`. In case `schedule` methods are called from `DispatchQueue.main`, it will perform action immediately without scheduling.

This scheduler is usually used to perform UI work.

Main scheduler is a specialization of `SerialDispatchQueueScheduler`.

This scheduler is optimized for `observeOn` operator. To ensure observable sequence is subscribed on main thread using `subscribeOn`
operator please use `ConcurrentMainScheduler` because it is more optimized for that purpose.
*/
public final class MainScheduler : SerialDispatchQueueScheduler, @unchecked Sendable {

    private let mainQueue: DispatchQueue

    let numberEnqueued = AtomicInt(0)

    /// Initializes new instance of `MainScheduler`.
    public init() {
        self.mainQueue = DispatchQueue.main
        super.init(serialQueue: self.mainQueue)
    }

    /// Singleton instance of `MainScheduler`
    public static let instance = MainScheduler()

    /// Singleton instance of `MainScheduler` that always schedules work asynchronously
    /// and doesn't perform optimizations for calls scheduled from main queue.
    public static let asyncInstance = SerialDispatchQueueScheduler(serialQueue: DispatchQueue.main)

    /// In case this method is called on a background thread it will throw an exception.
    public static func ensureExecutingOnScheduler(errorMessage: String? = nil) {
        if !DispatchQueue.isMain {
            rxFatalError(errorMessage ?? "Executing on background thread. Please use `MainScheduler.instance.schedule` to schedule work on main thread.")
        }
    }

    /// In case this method is running on a background thread it will throw an exception.
    public static func ensureRunningOnMainThread(errorMessage: String? = nil) {
        #if !os(Linux) // isMainThread is not implemented in Linux Foundation
            guard Thread.isMainThread else {
                rxFatalError(errorMessage ?? "Running on background thread.")
            }
        #endif
    }

    override func scheduleInternal<StateType>(_ state: StateType, action: @escaping @Sendable (StateType) -> Disposable) -> Disposable {
        let previousNumberEnqueued = increment(self.numberEnqueued)

        if DispatchQueue.isMain && previousNumberEnqueued == 0 {
            let disposable = action(state)
            decrement(self.numberEnqueued)
            return disposable
        }

        let cancel = SingleAssignmentDisposable()

        self.mainQueue.async {
            if !cancel.isDisposed {
                cancel.setDisposable(action(state))
            }

            decrement(self.numberEnqueued)
        }

        return cancel
    }
}

extension MainScheduler {
    // implementation copied from from assumeIsolated. This is copied because assumeIsolated has @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *). This implementation also remove the check that the closure is executed on the main actor.
    @preconcurrency nonisolated
    static private func _assumeMainActor<T>(execute operation: @MainActor(unsafe) () throws -> T) rethrows -> T {
        typealias YesActor = @MainActor () throws -> T
        typealias NoActor = () throws -> T
        
        // To do the unsafe cast, we have to pretend it's @escaping.
        return try withoutActuallyEscaping(operation) { (_ fn: @escaping YesActor) throws -> T in
            let rawFn = unsafeBitCast(fn, to: NoActor.self)
            return try rawFn()
        }
    }
    
    @preconcurrency nonisolated
    static public func assumeMainActor<T>(execute operation: @MainActor(unsafe) () throws -> T) rethrows -> T {
        ensureRunningOnMainThread()
        return try _assumeMainActor(execute: operation)
    }
    
    public static func assumeMainActor<T>(_ work: @escaping @Sendable @MainActor(assumed) () -> T) -> (@Sendable () -> T) {
        return { @Sendable () -> T in
            return MainScheduler.assumeMainActor(execute: { return work() })
        }
    }
    
    public static func assumeMainActor<T, Value>(_ work: @escaping @Sendable @MainActor(assumed) (Value) -> T) -> (@Sendable (Value) -> T) {
        return { @Sendable (value: Value) -> T in
            return MainScheduler.assumeMainActor(execute: { return work(value) })
        }
    }
    
    public static func assumeMainActor<T, Value1, Value2>(_ work: @escaping @Sendable @MainActor(assumed) (Value1, Value2) -> T) -> (@Sendable (Value1, Value2) -> T) {
        return { @Sendable (value1: Value1, value2: Value2) -> T in
            return MainScheduler.assumeMainActor(execute: { return work(value1, value2) })
        }
    }
    
    public static func tryExecuteInSync(execute: @escaping @Sendable @MainActor () -> Void) {
        let isMainThread = { () -> Bool in
#if !os(Linux) // isMainThread is not implemented in Linux Foundation
            return Thread.isMainThread
#else
            return DispatchQueue.isMain
#endif
        }()
        
        if isMainThread {
            Self.assumeMainActor(execute: execute)
        } else {
            DispatchQueue.main.async(execute: execute)
        }
    }
}
