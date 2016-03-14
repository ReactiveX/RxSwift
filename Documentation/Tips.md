Tips
====

* Always strive to model your systems or their parts as pure functions. Those pure functions can be tested easily and can be used to modify operator behaviors.
* When you are using Rx, first try to compose built-in operators.
* If using some combination of operators often, create your convenience operators.

e.g.
```swift
extension ObservableType where E: MaybeCool {

    @warn_unused_result(message="http://git.io/rxs.uo")
    public func coolElements()
        -> Observable<E> {
          return filter { e -> Bool in
              return e.isCool
          }
    }
}
```

  * Rx operators are as general as possible, but there will always be edge cases that will be hard to model. In those cases you can just create your own operator and possibly use one of the built-in operators as a reference.

  * Always use operators to compose subscriptions.

  **Avoid nesting subscribe calls at all cost. This is a bad smell.**

  ```swift
  textField.rx_text.subscribeNext { text in
      performURLRequest(text).subscribeNext { result in
          ...
      }
      .addDisposableTo(disposeBag)
  }
  .addDisposableTo(disposeBag)
  ```

  **Preferred way of chaining disposables by using operators.**

  ```swift
  textField.rx_text
      .flatMapLatest { text in
          // Assuming this doesn't fail and returns result on main scheduler,
          // otherwise `catchError` and `observeOn(MainScheduler.instance)` can be used to
          // correct this.
          return performURLRequest(text)
      }
      ...
      .addDisposableTo(disposeBag) // only one top most disposable
  ```
