## Swift Concurrency

Swift 5.5 introduced a new long-awaited concurrency model for Swift, using the new `async`/`await` syntax.

Starting with RxSwift 6.5, you can `await` on your `Observable`s and other reactive units as if they were async operations or sequences, and you can also convert `async` pieces of work into `Observable`s.

### `await`ing values emitted by `Observable`

There are three variations to `await`ing values emitted by `Observable`s - depending on the amount of values a trait emits, and whether or not it's throwing.

The three variations are: awaiting a sequence, awaiting a non-throwing sequence, or awaiting a single value.

#### Awaiting a throwing sequence

`Observable`s by default may emit an error. As such, in the `async`/`await` world - they may _throw_ an error.

You can iterate over the entirety of an `Observable`'s life time and elements like so:

```swift
do {
    for try await value in observable.values {
        print("Got a value:", value)
    }
} catch {
    print("Got an error:", error)
}
```

Note that the `Observable` must complete, or the async task will suspend and never resume back to the parent task.

#### Awaiting a non-throwing sequence

`Infallible`, `Driver`, and `Signal` are all guaranteed to never emit errors (as opposed to `Observable`), so you may directly iterate over their values without worrying about catching any errors:

```swift
for await value in infallible.values {
    print("Got a value:", value)
}
```

#### Awaiting a single value

As opposed to the possibly-infinite sequences above, primitive sequences are guaranteed to only emit zero or one values. In those cases, you can simply await their value directly:

```swift
let value1 = try await single.value // Element
let value2 = try await maybe.value // Element?
let value3 = try await completable.value // Void
```

> **Note**: If a `Maybe` completes without emitting a value, it returns `nil` instead. A `Completable`, on the other hand, simply returns `Void` to note it finished its work.

### Wrapping an `async` Task as an `Observable`

If you already have an `AsyncSequence`-conforming asynchronous sequence at hand (such as an `AsyncStream`), you can bridge it back to the Rx world by simply using `asObservable()`:

```swift
let stream = AsyncStream { ... }

stream.asObservable()
    .subscribe(
        onNext: { ... },
        onError: { ... }
    )
```

### Wrapping an `async` result as a `Single`

If you already have an async piece of work that returns a single result you wish to await, you can bridge it back to the Rx world by using `Single.create`, a special overload which takes an `async throws` closure where you can simply await your async work:

```swift
func doIncredibleWork() async throws -> AmazingResponse {
    ...
}

let single = Single.create {
    try await doIncredibleWork()
} // Single<AmazingResponse>
```
