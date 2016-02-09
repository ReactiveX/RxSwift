Warnings
========

### <a name="unused-disposable"></a>Unused disposable (unused-disposable)

The following is valid for the `subscribe*`, `bind*` and `drive*` family of functions that return `Disposable`.

Warning is probably presented in a context similar to this one:

```Swift
let xs: Observable<E> ....

xs
  .filter { ... }
  .map { ... }
  .switchLatest()
  .subscribe(onNext: {
    ...
  }, onError: {
    ...
  })  
```

The `subscribe` function returns a subscription `Disposable` that can be used to cancel computation and free resources.

The preferred way of terminating these fluent calls is by using a `DisposeBag`, either through chaining a call to `.addDisposableTo(disposeBag)` or by adding the disposable directly to the bag.

```Swift
let xs: Observable<E> ....
let disposeBag = DisposeBag()

xs
  .filter { ... }
  .map { ... }
  .switchLatest()
  .subscribe(onNext: {
    ...
  }, onError: {
    ...
  })
  .addDisposableTo(disposeBag) // <--- note `addDisposableTo`
```

When `disposeBag` gets deallocated, the disposables contained in it will be automatically disposed.

In the case where `xs` terminates in a predictable way with either a `Completed` or `Error` message, not handling the subscription `Disposable` won't leak any resources. However, even in this case, using a dispose bag is still the preferred way to handle subscription disposables. It ensures that element computation is always terminated at a predictable moment, and makes your code robust and future proof because resources will be properly disposed even if the implementation of `xs` changes.

Another way to make sure subscriptions and resources are tied with the lifetime of some object is by using the `takeUntil` operator.

```Swift
let xs: Observable<E> ....
let someObject: NSObject  ...

_ = xs
  .filter { ... }
  .map { ... }
  .switchLatest()
  .takeUntil(someObject.rx_deallocated) // <-- note the `takeUntil` operator
  .subscribe(onNext: {
    ...
  }, onError: {
    ...
  })
```

If ignoring the subscription `Disposable` is desired behavior, this is how to silence the compiler warning.

```Swift
let xs: Observable<E> ....

_ = xs // <-- note the underscore
  .filter { ... }
  .map { ... }
  .switchLatest()
  .subscribe(onNext: {
    ...
  }, onError: {
    ...
  })
```

### <a name="unused-observable"></a>Unused observable sequence (unused-observable)

Warning is probably presented in a context similar to this one:

```Swift
let xs: Observable<E> ....

xs
  .filter { ... }
  .map { ... }
```

This code defines an observable sequence that is filtered and mapped from the `xs` sequence but then ignores the result.

Since this code just defines an observable sequence and then ignores it, it doesn't actually do anything.

Your intention was probably to either store the observable sequence definition and use it later ...

```Swift
let xs: Observable<E> ....

let ys = xs // <--- names definition as `ys`
  .filter { ... }
  .map { ... }
```

... or start computation based on that definition  

```Swift
let xs: Observable<E> ....
let disposeBag = DisposeBag()

xs
  .filter { ... }
  .map { ... }
  .subscribeNext { nextElement in       // <-- note the `subscribe*` method
    // use the element
    print(nextElement)
  }
  .addDisposableTo(disposeBag)
```
