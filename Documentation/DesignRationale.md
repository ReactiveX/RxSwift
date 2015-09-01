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
