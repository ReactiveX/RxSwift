**Content**

1. [Simple example]

## Simple example

To understand these examples, you will need to understand to `>-` operator.

This is the definition of `>-` operator

```swift
func >- <In, Out>(lhs: In, rhs: In -> Out) -> Out {
    return rhs(lhs)
}
```
More practical explanation

```
a >- b >- c equals c(b(a))
```

Let's first start with some imperative swift code.
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

This is not the wanted behaviour.

To integrate RxSwift framework into your project just include framework in your project and write `import RxSwit`.

This is the same logic using RxSwift.

```swift
let a /*: Observable<Int>*/ = Variable(1)   // a = 1
let b /*: Observable<Int>*/ = Variable(2)   // b = 2

// This will "bind" rx variable `c` to definition
// if a + b >= 0 {
//      c = "\(a + b) is positive"
// }
let c = combineLatest(a, b) { $0 + $1 }     // combines latest values of variables `a` and `b` using `+`
	>- filter { $0 >= 0 }               // if `a + b >= 0` is true, `a + b` is passed to map operator
	>- map { "\($0) is positive" }      // maps `a + b` to "\(a + b) is positive"

// Since initial values are a = 1, b = 2
// 1 + 2 = 3 which is >= 0, `c` is intially equal to "3 is positive"

// To pull values out of rx variable `c`, subscribe to values from  `c`.
// `subscribeNext` means subscribe to next (fresh) values of variable `c`.
// That also includes the inital value "3 is positive".
c >- subscribeNext { println($0) }          // prints: "3 is positive"

// Now let's increase the value of `a`
// a = 4 is in RxSwift
a.next(4)                                   // prints: 6 is positive
// Sum of latest values is now `4 + 2`, `6` is >= 0, map operator
// produces "6 is positive" and that result is "assigned" to `c`.
// Since the value of `c` changed, `{ println($0) }` will get called, 
// and "6 is positive" is printed.

// Now let's change the value of `b`
// b = -8 is in RxSwift
b.next(-8)                                  // doesn't print anything
// Sum of latest values is `4 + (-8)`, `-4` is not >= 0, map doesn't 
// get executed.
// That means that `c` still contains "6 is positive" and that's correct.
// Since `c` hasn't been updated, that means next value hasn't been produced,
// and `{ println($0) }` won't be called.

// ...
```

If you have a `|>` operator defined as a pipe operator in your project, you can use it too instead of `>-` operator

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

// immediately prints: 3 is positive
combineLatest(a, b) { $0 + $1 } 
    |> filter { $0 >= 0 } 
    |> map { "\($0) is positive" }
    |> subscribeNext { println($0) }
```

The choice is yours.
