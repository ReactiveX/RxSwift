Warnings
========

### <a name="unused-disposable"></a>Unused disposable (unused-disposable)

The same is valid for `subscribe*`, `bind*` and `drive*` family of functions that return `Disposable`.

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

`subscribe` function returns a subscription `Disposable` that can be used to cancel computation and free resources.

Preferred way of terminating these fluent calls is by using `.addDisposableTo(disposeBag)` or in some equivalent way.

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

When `disposeBag` gets deallocated, subscription will be automatically disposed.

In case `xs` terminates in a predictable way with `Completed` or `Error` message, not handling subscription `Disposable` won't leak any resources, but it's still preferred way because in that way element computation is terminated at predictable moment.

That will also make your code robust and future proof because resources will be properly disposed even if `xs` implementation changes.

Another way to make sure subscriptions and resources are tied with the lifetime of some object is by using `takeUntil` operator.

```Swift
let xs: Observable<E> ....
let someObject: NSObject  ...

_ = xs
  .filter { ... }
  .map { ... }
  .switchLatest()
  .takeUntil(someObject.rx_dellocated) // <-- note the `takeUntil` operator
  .subscribe(onNext: {
    ...
  }, onError: {
    ...
  })
```

If ignoring the subscription `Disposable` is desired behavior, this is how to silence the compiler warning.

```Swift
let xs: Observable<E> ....
let disposeBag = DisposeBag()

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

This code defines observable sequence that is filtered and mapped `xs` sequence but then ignores the result.

Since this code just defines an observable sequence and then ignores it, it doesn't actually do nothing and it's pretty much useless.

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
    ... probably print or something
  }
  .addDisposableTo(disposeBag)
```
