//
//  AsyncLock.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/**
 In case nobody holds this lock, the work will be queued and executed immediately
 on thread that is requesting lock.

 In case there is somebody currently holding that lock, action will be enqueued.
 When owned of the lock finishes with it's processing, it will also execute
 and pending work.

 That means that enqueued work could possibly be executed later on a different thread.
 */
final class AsyncLock<I: InvocableType>:
    Disposable,
    Lock,
    SynchronizedDisposeType
{
    typealias Action = () -> Void

    private var _lock = SpinLock()

    private var queue: Queue<I> = Queue(capacity: 0)

    private var isExecuting: Bool = false
    private var hasFaulted: Bool = false

    /**
     Locks the current instance, preventing other threads from modifying it until `unlock()` is called.

     This method is used to create a critical section where only one thread is allowed to access the protected resources at a time.

     Example usage:
     ```swift
     let lock = AsyncLock<SomeAction>()
     lock.lock()
     // Critical section
     lock.unlock()
     ```
     */
    func lock() {
        _lock.lock()
    }

    /**
     Unlocks the current instance, allowing other threads to access the protected resources.

     This method is called after a `lock()` to release the critical section, ensuring that other waiting threads can proceed.

     Example usage:
     ```swift
     let lock = AsyncLock<SomeAction>()
     lock.lock()
     // Critical section
     lock.unlock()
     ```
     */
    func unlock() {
        _lock.unlock()
    }

    // MARK: - Queue Methods

    /**
     Enqueues an action into the internal queue for deferred execution.

     If no actions are currently being executed, the method returns the action for immediate execution. Otherwise, the action is enqueued for deferred execution when the lock is available.

     - Parameter action: The action to enqueue.
     - Returns: The action if it can be executed immediately, or `nil` if it has been enqueued.

     Example usage:
     ```swift
     let lock = AsyncLock<SomeAction>()
     if let action = lock.enqueue(someAction) {
     action.invoke()  // Execute the action immediately if it's not deferred.
     }
     ```
     */
    private func enqueue(_ action: I) -> I? {
        lock(); defer { self.unlock() }
        if hasFaulted {
            return nil
        }

        if isExecuting {
            queue.enqueue(action)
            return nil
        }

        isExecuting = true

        return action
    }

    /**
     Dequeues the next action for execution, if available.

     If the queue is empty, this method resets the `isExecuting` flag to indicate that no actions are currently being executed.

     - Returns: The next action from the queue, or `nil` if the queue is empty.

     Example usage:
     ```swift
     let nextAction = lock.dequeue()
     nextAction?.invoke()  // Execute the next action if one is available.
     ```
     */
    private func dequeue() -> I? {
        lock(); defer { self.unlock() }
        if !queue.isEmpty {
            return queue.dequeue()
        } else {
            isExecuting = false
            return nil
        }
    }

    /**
     Invokes the provided action, ensuring that actions are executed sequentially.

     The first action is executed immediately if no other actions are currently running. If other actions are already in the queue, the new action is enqueued and executed sequentially after the current actions are completed.

     - Parameter action: The action to be invoked.

     Example usage:
     ```swift
     let lock = AsyncLock<SomeAction>()
     lock.invoke(someAction)  // Invoke or enqueue the action.
     ```
     */
    func invoke(_ action: I) {
        let firstEnqueuedAction = enqueue(action)

        if let firstEnqueuedAction {
            firstEnqueuedAction.invoke()
        } else {
            // action is enqueued, it's somebody else's concern now
            return
        }

        while true {
            let nextAction = dequeue()

            if let nextAction {
                nextAction.invoke()
            } else {
                return
            }
        }
    }

    // MARK: - Dispose Methods

    /**
     Disposes of the `AsyncLock` by clearing the internal queue and preventing further actions from being executed.

     This method ensures that all pending actions are discarded, and the lock enters a faulted state where no new actions can be enqueued or executed.

     Example usage:
     ```swift
     let lock = AsyncLock<SomeAction>()
     lock.dispose()  // Clear the queue and prevent further actions.
     ```
     */
    func dispose() {
        synchronizedDispose()
    }

    /**
     Synchronously disposes of the internal queue and marks the lock as faulted.

     This method is typically used internally to handle disposal of the lock in a thread-safe manner.

     Example usage:
     ```swift
     lock.synchronized_dispose()
     ```
     */
    func synchronized_dispose() {
        queue = Queue(capacity: 0)
        hasFaulted = true
    }
}
