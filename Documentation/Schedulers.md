# Schedulers

1. [Serial vs Concurrent Schedulers](#serial-vs-concurrent-schedulers)
1. [Custom schedulers](#custom-schedulers)
1. [Builtin schedulers](#builtin-schedulers)

Schedulers abstract away the mechanism for performing work.

Different mechanisms for performing work include the current thread, dispatch queues, operation queues, new threads, thread pools, and run loops.

There are two main operators that work with schedulers, `observeOn` and `subscribeOn`.

If you want to perform work on a different scheduler just use `observeOn(scheduler)` operator.

You would usually use `observeOn` a lot more often than `subscribeOn`.

In case `observeOn` isn't explicitly specified, work will be performed on whichever thread/scheduler elements are generated.

Example of using the `observeOn` operator:

```swift
sequence1
  .observeOn(backgroundScheduler)
  .map { n in
      print("This is performed on the background scheduler")
  }
  .observeOn(MainScheduler.instance)
  .map { n in
      print("This is performed on the main scheduler")
  }
```

If you want to start sequence generation (`subscribe` method) and call dispose on a specific scheduler, use `subscribeOn(scheduler)`.

In case `subscribeOn` isn't explicitly specified, the `subscribe` closure (closure passed to `Observable.create`) will be called on the same thread/scheduler on which `subscribe(onNext:)` or `subscribe` is called.

In case `subscribeOn` isn't explicitly specified, the `dispose` method will be called on the same thread/scheduler that initiated disposing.

In short, if no explicit scheduler is chosen, those methods will be called on current thread/scheduler.

## Serial vs Concurrent Schedulers

Since schedulers can really be anything, and all operators that transform sequences need to preserve additional [implicit guarantees](GettingStarted.md#implicit-observable-guarantees), it is important what kind of schedulers are you creating.

In case the scheduler is concurrent, Rx's `observeOn` and `subscribeOn` operators will make sure everything works perfectly.

If you use some scheduler that Rx can prove is serial, it will be able to perform additional optimizations.

So far it only performs those optimizations for dispatch queue schedulers.

In case of serial dispatch queue schedulers, `observeOn` is optimized to just a simple `dispatch_async` call.

## Custom schedulers

Besides current schedulers, you can write your own schedulers.

If you just want to describe who needs to perform work immediately, you can create your own scheduler by implementing the `ImmediateScheduler` protocol.

```swift
public protocol ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}
```

If you want to create a new scheduler that supports time based operations, then you'll need to implement the `Scheduler` protocol:

```swift
public protocol Scheduler: ImmediateScheduler {
    associatedtype TimeInterval
    associatedtype Time

    var now : Time {
        get
    }

    func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}
```

In case the scheduler only has periodic scheduling capabilities, you can inform Rx by implementing the `PeriodicScheduler` protocol:

```swift
public protocol PeriodicScheduler : Scheduler {
    func schedulePeriodic<StateType>(state: StateType, startAfter: TimeInterval, period: TimeInterval, action: (StateType) -> StateType) -> RxResult<Disposable>
}
```

In case the scheduler doesn't support `PeriodicScheduling` capabilities, Rx will emulate periodic scheduling transparently.

## Builtin schedulers

Rx can use all types of schedulers, but it can also perform some additional optimizations if it has proof that scheduler is serial.

These are the currently supported schedulers:

### CurrentThreadScheduler (Serial scheduler)

Schedules units of work on the current thread.
This is the default scheduler for operators that generate elements.

This scheduler is also sometimes called a "trampoline scheduler".

If `CurrentThreadScheduler.instance.schedule(state) { }` is called for the first time on some thread, the scheduled action will be executed immediately and a hidden queue will be created where all recursively scheduled actions will be temporarily enqueued.

If some parent frame on the call stack is already running `CurrentThreadScheduler.instance.schedule(state) { }`, the scheduled action will be enqueued and executed when the currently running action and all previously enqueued actions have finished executing.

### MainScheduler (Serial scheduler)

Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform the action immediately without scheduling.

This scheduler is usually used to perform UI work.

### SerialDispatchQueueScheduler (Serial scheduler)

Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. It will make sure that even if a concurrent dispatch queue is passed, it's transformed into a serial one.

Serial schedulers enable certain optimizations for `observeOn`.

The main scheduler is an instance of `SerialDispatchQueueScheduler`.

### ConcurrentDispatchQueueScheduler (Concurrent scheduler)

Abstracts the work that needs to be performed on a specific `dispatch_queue_t`. You can also pass a serial dispatch queue, it shouldn't cause any problems.

This scheduler is suitable when some work needs to be performed in the background.

### OperationQueueScheduler (Concurrent scheduler)

Abstracts the work that needs to be performed on a specific `NSOperationQueue`.

This scheduler is suitable for cases when there is some bigger chunk of work that needs to be performed in the background and you want to fine tune concurrent processing using `maxConcurrentOperationCount`.
