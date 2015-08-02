Design Rationale
================

## Why error type isn't generic

```Swift
enum Event<Element>  {
    case Next(Element)      // next element of a sequence
    case Error(ErrorType)   // sequence failed with error
    case Completed          // sequence terminated successfully
}
```

Let's discuss pros and cons of `ErrorType` being generic.

If you have generic error type you create additional impedance mismatch between two observables.

Let's say you have:

`Observable<String, E1>` and `Observable<String, E2>`

There isn't much you can do with them without figuring out what will be the resulting error type.

Will it be `E1`, `E2` or some new `E3` maybe? So you need a new set of operators just to solve that impedance mismatch.

This for sure hurts composition properties, and Rx really doesn't care about why sequence fails, it just usually forwards failure further down the observable chain.

There is additional problem that maybe in some cases operators will fail for some internal error, and in that case you won't be able to construct resulting error and report failure.

But ok, let's ignore that and assume we can use that to model sequences that don't error out. It looks like it could be useful for that purpose?

Well yes, it potentially could be, but lets consider why would you want to use sequences that don't error out.

One obvious application would be for permanent streams in UI layer that drive entire UI. But when you consider that case, it's not really only sufficient to use compiler to prove that sequences don't error out, you also need to prove other properties. Like that elements are observed on `MainScheduler`.

What you really need is a generic way to prove traits for sequences (`Observables`). And you could be interested in a lot of properties. For example:

* sequence terminates in finite time (server side)
* sequence contains only one element (if you are running some computation)
* sequence doesn't error out, never terminates and elements are delivered on main scheduler (UI)
* sequence doesn't error out, never terminates and elements are delivered on main scheduler, and has refcounted sharing (UI)
* sequence doesn't error out, never terminates and elements are delivered on specific background scheduler (audio engine)

What you really want is a general compiler enforced system of traits for observable sequences, and a set of invariant operators for those wanted properties.

A good analogy IMHO would be

```
1, 3.14, e, 2.79, 1 + 1i      <->    Observable<E>
1m/s, 1T, 5kg, 1.3 pounds     <->    Errorless observable, UI observable, Finite observable ...
```

There are many ways how to do that in Swift by either using composition or inheritance of observables.

Additional benefit of using unit system is that you can prove that UI code is executing on same scheduler and thus use lockless operators for all transformations.

Since Rx already doesn't have locks for single sequence operations, and all of the remaining locks are in statefull components (aka UI), that would practically remove all of the remaining locks out of Rx code and create compiler enforced lockless Rx code.

So IMHO, there really is no benefit of using typed Errors that couldn't be achieved cleaner in other ways while preserving Rx compositional semantics. And other ways also have huge other benefits.

## Pipe operator

This is the definition of `>-` operator.

```swift
func >- <In, Out>(lhs: In, rhs: In -> Out) -> Out {
    return rhs(lhs)
}
```

This enables us to write

```swift
a >- map { $0 * 2 } >- filter { $0 > 0 }
```

instead of

```swift
a.map { $0 * 2 }.filter { $0 > 0 }
```

This is another explanation:

```swift
a >- b >- c is equivalent to c(b(a))
```

So why was this introduced and not just use "." and extensions? Short answer is that Swift extensions weren't powerful enough, but there are other reasons as well.

Next version of RxSwift for Swift 2.0 will probably also include extensions that will enable the use of
`.`.

">-" also enables us to chain results easily. For example, if using protocol extensions typical example would look like this.

```swift
disposeBag.addDisposable(
    observable
      .map { n in
          n * 2
      }
      .subscribeNext { n in
          print(n)
      }
  )
```

This code could be written more elegantly using `>-` operator.

```swift
observable
    >- map { n in
        n * 2
    }
    >- subscribeNext { n in
        print(n)
    }
    >- disposeBag.addDisposable
```

None of the Rx public interfaces depend on the >- operator.

It was actually introduced quite late and you can use Rx operators (map, filter ...) without it.

### Replacing `>-` with your own operator

If you dislike `>-` operator and want to use `|>` or `~>` operators, just define them in your project in this form:

```swift
infix operator |> { associativity left precedence 91 }

public func |> <In, Out>(source: In, @noescape transform: In -> Out) -> Out {
    return transform(source)
}
```

or

```swift
infix operator ~> { associativity left precedence 91 }

public func ~> <In, Out>(source: In, @noescape transform: In -> Out) -> Out {
    return transform(source)
}
```

and you can use them instead of `>-` operator.

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

combineLatest(a, b) { $0 + $1 }
    |> filter { $0 >= 0 }
    |> map { "\($0) is positive" }
    |> subscribeNext { println($0) }
```

```swift
let a /*: Observable<Int>*/ = Variable(1)
let b /*: Observable<Int>*/ = Variable(2)

combineLatest(a, b) { $0 + $1 }
    ~> filter { $0 >= 0 }
    ~> map { "\($0) is positive" }
    ~> subscribeNext { println($0) }
```

### Why wasn't standard function application operator used?

I've first tried to find a similar operator in swift core libraries, but couldn't find it. That meant that I'll need to define something myself or find some third party library that contains reference function application operator definition and use it.
Otherwise all of the example code would be unreadable.

### Why wasn't some standard library used for that operator?

Well, I'm not sure there is a clear consensus in the community about funtion application operators or libraries that define them.

### Why wasn't function application operator defined only for `Observables` and `Disposables`?

One of the solutions could have been to provide a specialized operator that just works for `Observables` and `Disposables`.
In that case, if an identically named general purpose function application operator is defined somewhere else, there would still be collision, priority or ambiguity problems.

### Why wasn't some more standard operator like `|>` or `~>` used?

`|>` or `~>` are probably more commonly used operators in swift, so if there was another definition for them in Rx as general purpose function application operators, there is a high probability they would collide with definitions in other frameworks or project.

The simplest and safest solution IMHO was to create some new operator that made sense in this context and there is a low probability anyone else uses it.
In case the operator naming choice was wrong, name is rare and community eventually reaches consensus on the matter, it's more easier to find and replace it in user projects.

### Rationale why `>-` was chosen

* It's short, only two characters
* It looks like a sink to the right, which is a function it actually performs, so it's intuitive.
* It doesn't create a lot of visual noise. `|>` compared to `>-` IMHO looks a lot more intrusive. When my visual cortex parses `|>` it creates an illusion of a filled triangle, and when it parses `>-`, it sees three lines that don't cover any surface area, but are easily recognizable. Of course, that experience can be different for other people, but since I really wanted to create something that's pleasurable for me to use, that's a good argument. I'm just hoping that other people have the same experience.
* In the worst case scenario, if this operator is awkward to somebody, they can easily replace it using instructions above.
