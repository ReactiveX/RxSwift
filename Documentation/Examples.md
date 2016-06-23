Examples
========

1. [Calculated variable](#calculated-variable)
1. [Simple UI bindings](#simple-ui-bindings)
1. [Autocomplete](#autocomplete)
1. [more examples](../RxExample)
1. [Playgrounds](Playgrounds.md)

## Calculated variable

First, let's start with some imperative code.
The purpose of this example is to bind the identifier `c` to a value calculated from `a` and `b` if some condition is satisfied.

Here is the imperative code that calculates the value of `c`:

```swift
// this is standard imperative code
var c: String
var a = 1       // this will only assign the value `1` to `a` once
var b = 2       // this will only assign the value `2` to `b` once

if a + b >= 0 {
    c = "\(a + b) is positive" // this will only assign the value to `c` once
}
```

The value of `c` is now `3 is positive`. However, if we change the value of `a` to `4`, `c` will still contain the old value.

```swift
a = 4           // `c` will still be equal to "3 is positive" which is not good
                // we want `c` to be equal to "6 is positive" since 4 + 2 = 6
```

This is not the desired behavior.

This is the improved logic using RxSwift:

```swift
let a /*: Observable<Int>*/ = Variable(1)   // a = 1
let b /*: Observable<Int>*/ = Variable(2)   // b = 2

// combines latest values of variables `a` and `b` using `+`
let c = Observable.combineLatest(a.asObservable(), b.asObservable()) { $0 + $1 }
	.filter { $0 >= 0 }               // if `a + b >= 0` is true, `a + b` is passed to the map operator
	.map { "\($0) is positive" }      // maps `a + b` to "\(a + b) is positive"

// Since the initial values are a = 1 and b = 2
// 1 + 2 = 3 which is >= 0, so `c` is initially equal to "3 is positive"

// To pull values out of the Rx `Observable` `c`, subscribe to values from `c`.
// `subscribeNext` means subscribe to the next (fresh) values of `c`.
// That also includes the initial value "3 is positive".
c.subscribeNext { print($0) }          // prints: "3 is positive"

// Now, let's increase the value of `a`
a.value = 4                                   // prints: 6 is positive
// The sum of the latest values, `4` and `2`, is now `6`.
// Since this is `>= 0`, the `map` operator produces "6 is positive"
// and that result is "assigned" to `c`.
// Since the value of `c` changed, `{ print($0) }` will get called,
// and "6 is positive" will be printed.

// Now, let's change the value of `b`
b.value = -8                                 // doesn't print anything
// The sum of the latest values, `4 + (-8)`, is `-4`.
// Since this is not `>= 0`, `map` doesn't get executed.
// This means that `c` still contains "6 is positive"
// Since `c` hasn't been updated, a new "next" value hasn't been produced,
// and `{ print($0) }` won't be called.
```

## Simple UI bindings

* Instead of binding to variables, let's bind to `UITextField` values using the `rx_text` property
* Next, `map` the `String` into an `Int` and determine if the number is prime using an async API
* If the text is changed before the async call completes, a new async call will replace it via `concat`
* Bind the results to a `UILabel`

```swift
let subscription/*: Disposable */ = primeTextField.rx_text      // type is Observable<String>
            .map { WolframAlphaIsPrime(Int($0) ?? 0) }          // type is Observable<Observable<Prime>>
            .concat()                                           // type is Observable<Prime>
            .map { "number \($0.n) is prime? \($0.isPrime)" }   // type is Observable<String>
            .bindTo(resultLabel.rx_text)                        // return Disposable that can be used to unbind everything

// This will set `resultLabel.text` to "number 43 is prime? true" after
// server call completes.
primeTextField.text = "43"

// ...

// to unbind everything, just call
subscription.dispose()
```

All of the operators used in this example are the same operators used in the first example with variables. There's nothing special about it.

## Autocomplete

If you are new to Rx, the next example will probably be a little overwhelming at first. However, it's here to demonstrate how RxSwift code looks in the real-world.

This example contains complex async UI validation logic with progress notifications.
All operations are cancelled the moment `disposeBag` is deallocated.

Let's give it a shot.

```swift
// bind UI control values directly
// use username from `usernameOutlet` as username values source
self.usernameOutlet.rx_text
    .map { username in

        // synchronous validation, nothing special here
        if username.isEmpty {
            // Convenience for constructing synchronous result.
            // In case there is mixed synchronous and asynchronous code inside the same
            // method, this will construct an async result that is resolved immediately.
            return Observable.just((valid: false, message: "Username can't be empty."))
        }

        // ...

        // User interfaces should probably show some state while async operations
        // are executing.
        // Let's assume that we want to show "Checking availability" while waiting for a result.
        // Valid parameters can be:
        //  * true  - is valid
        //  * false - is not valid
        //  * nil   - validation pending
        typealias LoadingInfo = (valid: String?, message: String?)
        let loadingValue : LoadingInfo = (valid: nil, message: "Checking availability ...")

        // This will fire a server call to check if the username already exists.
        // Its type is `Observable<ValidationResult>`
        return API.usernameAvailable(username)
          .map { available in
              if available {
                  return (true, "Username available")
              }
              else {
                  return (false, "Username already taken")
              }
          }
          // use `loadingValue` until server responds
          .startWith(loadingValue)
    }
// Since we now have `Observable<Observable<ValidationResult>>`
// we need to somehow return to a simple `Observable<ValidationResult>`.
// We could use the `concat` operator from the second example, but we really
// want to cancel pending asynchronous operations if a new username is provided.
// That's what `switchLatest` does.
    .switchLatest()
// Now we need to bind that to the user interface somehow.
// Good old `subscribeNext` can do that.
// That's the end of `Observable` chain.
    .subscribeNext { valid in
        errorLabel.textColor = validationColor(valid)
        errorLabel.text = valid.message
    }
// This will produce a `Disposable` object that can unbind everything and cancel
// pending async operations.
// Instead of doing it manually, which is tedious,
// let's dispose everything automagically upon view controller dealloc.
    .addDisposableTo(disposeBag)
```

It doesn't get any simpler than that. There are [more examples](../RxExample) in the repository, so feel free to check them out.

They include examples on how to use Rx in the context of MVVM pattern or without it.
