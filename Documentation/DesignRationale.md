Design Rationale
================

## Why error type isn't generic

```Swift
enum Event<Element>  {
    case Next(Element)      // next element of a sequence
    case Error(Error)   // sequence failed with error
    case Completed          // sequence terminated successfully
}
```

Let's discuss the pros and cons of `Error` being generic.

If you have a generic error type, you create additional impedance mismatch between two observables.

Let's say you have:

`Observable<String, E1>` and `Observable<String, E2>`

There isn't much you can do with them without figuring out what the resulting error type will be.

Will it be `E1`, `E2` or some new `E3` maybe? So, you would need a new set of operators just to solve that impedance mismatch.

This hurts composition properties, and Rx isn't concerned with why a sequence fails, it just usually forwards failures further down the observable chain.

There is an additional problem that, in some cases, operators might fail due to some internal error, in which case you wouldn't be able to construct a resulting error and report failure.

But OK, let's ignore that and assume we can use that to model sequences that don't error out. Could it be useful for that purpose?

Well yes, it potentially could be, but let's consider why you would want to use sequences that don't error out.

One obvious application would be for permanent streams in the UI layer that drive the entire UI. When you consider that case, it's not really sufficient to only use the compiler to prove that sequences don't error out, you also need to prove other properties. For instance, that elements are observed on `MainScheduler`.

What you really need is a generic way to prove traits for observable sequences. There are a lot of properties you could be interested in. For example:

* sequence terminates in finite time (server side)
* sequence contains only one element (if you are running some computation)
* sequence doesn't error out, never terminates and elements are delivered on main scheduler (UI)
* sequence doesn't error out, never terminates and elements are delivered on main scheduler, and has refcounted sharing (UI)
* sequence doesn't error out, never terminates and elements are delivered on specific background scheduler (audio engine)

What you really want is a general compiler-enforced system of traits for observable sequences, and a set of invariant operators for those wanted properties.

A good analogy would be:

```
1, 3.14, e, 2.79, 1 + 1i      <->    Observable<E>
1m/s, 1T, 5kg, 1.3 pounds     <->    Errorless observable, UI observable, Finite observable ...
```

There are many ways to do such a thing in Swift by either using composition or inheritance of observables.

An additional benefit of using a unit system is that you can prove that UI code is executing on the same scheduler and thus use lockless operators for all transformations.

Since RxSwift already doesn't have locks for single sequence operations, and all of the locks that do exist are in stateful components (e.g. UI), there are practically no locks in RxSwift code, which allows for such details to be compiler enforced.

There really is no benefit to using typed `Error`s that couldn't be achieved in other cleaner ways while preserving Rx compositional semantics.
