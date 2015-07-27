Schedulers
==========

From ReactiveX.io

> If you want to introduce multithreading into your cascade of Observable operators, you can do so by instructing those operators (or particular Observables) to operate on particular Schedulers.

> Some ReactiveX Observable operators have variants that take a Scheduler as a parameter. These instruct the operator to do some or all of its work on a particular Scheduler.

> You can make an Observable act on a particular Scheduler by means of the ObserveOn or SubscribeOn operators. ObserveOn instructs an Observable to call its observer’s onNext, onError, and onCompleted methods on a particular Scheduler; SubscribeOn takes this a step further and instructs the Observable to do all of its processing (including the sending of items and notifications to observers) on a particular Scheduler.

If you want to peform work on different scheduler just use `>- observeOn(scheduler)` operator.

You would usually use `observeOn` a lot more often then `subscribeOn`.

In case `observeOn` isn't explicitly specified, work will be performed on which ever thread/scheduler elements are generated.


For example

```
sequence1
  >- observeOn(backgroundScheduler)
  >- map { n in
      println("This is performed on background scheduler")
  }
  >- observeOn(MainScheduler.sharedInstance)
  >- map { n in
      println("This is performed on main scheduler")
  }
```

If you want to start sequence generation (`subscribe` method) and call dispose on a specific scheduler, use `>- subscribeOn(scheduler)`.

In case `subscribeOn` isn't explicitly specified, `subscribe` method will be called on the same thread/scheduler that `subscribeNext` is called.

In case `subscribeOn` isn't explicitly specified, `dispose` method will be called on the same thread/scheduler that initiating `dispose` is called.

In short, if no explicit schedulers are chosen, those methods will be called on current thread/scheduler.

# Custom schedulers

Besides current schedulers, you can write your own schedulers.

If you just want to describe who needs to perform work immediately, you can create your own scheduler by implementing `ImmediateScheduler` protocol.

```swift
public protocol ImmediateScheduler {
    func schedule<StateType>(state: StateType, action: (/*ImmediateScheduler,*/ StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}
```

If you want to create new scheduler that supports time based operations, then you'll need to implement.

```swift
public protocol Scheduler: ImmediateScheduler {
    typealias TimeInterval
    typealias Time

    var now : Time {
        get
    }

    func scheduleRelative<StateType>(state: StateType, dueTime: TimeInterval, action: (StateType) -> RxResult<Disposable>) -> RxResult<Disposable>
}
```

# Builtin schedulers

Rx can use all types of schedulers, but it can also perform some additional optimizations if it has proof that scheduler is serial.

These are currently supported schedulers

## MainScheduler (Serial scheduler)

Abstracts work that needs to be performed on `MainThread`. In case `schedule` methods are called from main thread, it will perform action immediately without scheduling.

## SerialDispatchQueueScheduler (Serial scheduler)

Abstracts the work that needs to be peformed on a specific `dispatch_queue_t`. It will make sure that even if concurrent dispatch queue is passed, it's transformed into a serial one.

Serial schedulers enable certain optimizations for `observeOn`.

## ConcurrentDispatchQueueScheduler (Concurrent scheduler)

Abstracts the work that needs to be peformed on a specific `dispatch_queue_t`. You can also pass a serial dispatch queue, it shouldn't cause any problems.

## OperationQueueScheduler (Concurrent scheduler)

Abstracts the work that needs to be peformed on a specific `NSOperationQueue`. You can use this scheduler to easily limit the number of parallel sequence processing.
