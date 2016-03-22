Examples
========

1. [Calculated variable](#calculated-variable)
1. [Simple UI bindings](#simple-ui-bindings)
1. [Autocomplete](#autocomplete)
1. [more examples](../RxExample)
1. [Playgrounds](Playgrounds.md)

## Calculated variable

Let's first start with some imperative swift code.Sw
The purpose of example is to bind identifier `c` to a value calculated from `a` and `b` if some condition is satisfied.

Here is the imperative swift code that calculates the value of `c`:

```swift
// this is usual imperative code
var c: String
var a = 1       // this will only assign value `1` to `a` once
var b = 2       // this will only assign value `2` to `b` once

if a + b >= 0 {
    c = "\(a + b) is positive" // this will only assign value to `c` once
}
```

The value of `c` is now `3 is positive`. But if we change the value of `a` to `4`, `c` will still contain the old value.

```swift
a = 4           // c will still be equal "3 is positive" which is not good
                // c should be equal to "6 is positive" because 4 + 2 = 6
```

This is not the wanted behavior.

To integrate RxSwift framework into your project just include framework in your project and write `import RxSwift`.

This is the same logic using RxSwift.

```swift
let a /*: Observable<Int>*/ = Variable(1)   // a = 1
let b /*: Observable<Int>*/ = Variable(2)   // b = 2

// This will "bind" rx variable `c` to definition
// if a + b >= 0 {
//      c = "\(a + b) is positive"
// }

// combines latest values of variables `a` and `b` using `+`
let c = Observable.combineLatest(a.asObservable(), b.asObservable()) { $0 + $1 }
	.filter { $0 >= 0 }               // if `a + b >= 0` is true, `a + b` is passed to map operator
	.map { "\($0) is positive" }      // maps `a + b` to "\(a + b) is positive"

// Since initial values are a = 1, b = 2
// 1 + 2 = 3 which is >= 0, `c` is intially equal to "3 is positive"

// To pull values out of rx variable `c`, subscribe to values from  `c`.
// `subscribeNext` means subscribe to next (fresh) values of variable `c`.
// That also includes the inital value "3 is positive".
c.subscribeNext { print($0) }          // prints: "3 is positive"

// Now let's increase the value of `a`
// a = 4 is in RxSwift
a.value = 4                                   // prints: 6 is positive
// Sum of latest values is now `4 + 2`, `6` is >= 0, map operator
// produces "6 is positive" and that result is "assigned" to `c`.
// Since the value of `c` changed, `{ print($0) }` will get called,
// and "6 is positive" is printed.

// Now let's change the value of `b`
// b = -8 is in RxSwift
b.value = -8                                 // doesn't print anything
// Sum of latest values is `4 + (-8)`, `-4` is not >= 0, map doesn't
// get executed.
// That means that `c` still contains "6 is positive" and that's correct.
// Since `c` hasn't been updated, that means next value hasn't been produced,
// and `{ print($0) }` won't be called.

// ...
```

## Simple UI bindings

* instead of binding to variables, let's bind to text field values (rx_text)
* next, parse that into an int and calculate if the number is prime using an async API (map)
* if text field value is changed before async call completes, new async call will be enqueued (concat)
* bind results to label (bindTo(resultLabel.rx_text))

```swift
let subscription/*: Disposable */ = primeTextField.rx_text      // type is Observable<String>
            .map { WolframAlphaIsPrime(Int($0) ?? 0) }       // type is Observable<Observable<Prime>>
            .concat()                                           // type is Observable<Prime>
            .map { "number \($0.n) is prime? \($0.isPrime)" }   // type is Observable<String>
            .bindTo(resultLabel.rx_text)                        // return Disposable that can be used to unbind everything

// This will set resultLabel.text to "number 43 is prime? true" after
// server call completes.
primeTextField.text = "43"

// ...

// to unbind everything, just call
subscription.dispose()
```

All of the operators used in this example are the same operators used in the first example with variables. Nothing special about it.

## Autocomplete

If you are new to Rx, next example will probably be a little overwhelming, but it's here to demonstrate how RxSwift code looks like in real world examples.

The third example is a real world, complex UI async validation logic, with progress notifications.
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
            // In case there is mixed synchronous and asychronous code inside the same
            // method, this will construct an async result that is resolved immediatelly.
            return Observable.just((valid: false, message: "Username can't be empty."))
        }

        ...

        // Every user interface probably shows some state while async operation
        // is executing.
        // Let's assume that we want to show "Checking availability" while waiting for result.
        // valid parameter can be
        //  * true  - is valid
        //  * false - not valid
        //  * nil   - validation pending
        typealias LoadingInfo = (valid : String?, message: String?)
        let loadingValue : LoadingInfo = (valid: nil, message: "Checking availability ...")

        // This will fire a server call to check if the username already exists.
        // Guess what, its type is `Observable<ValidationResult>`
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
// we somehow need to return to normal `Observable` world.
// We could use `concat` operator from second example, but we really
// want to cancel pending asynchronous operation if new username is
// provided.
// That's what `switchLatest` does
    .switchLatest()
// Now we need to bind that to the user interface somehow.
// Good old `subscribeNext` can do that
// That's the end of `Observable` chain.
// This will produce a `Disposable` object that can unbind everything and cancel
// pending async operations.
    .subscribeNext { valid in
        errorLabel.textColor = validationColor(valid)
        errorLabel.text = valid.message
    }
// Why would we do it manually, that's tedious,
// let's dispose everything automagically on view controller dealloc.
    .addDisposableTo(disposeBag)
```

Can't get any simpler than this. There are [more examples](../RxExample) in the repository, so feel free to check them out.

They include examples on how to use it in the context of MVVM pattern or without it.
