Unit Tests
==========

## Testing custom operators

RxSwift uses `RxTests` for all operator tests, located in the AllTests-* target inside the project `Rx.xcworkspace`.

This is an example of a typical `RxSwift` operator unit test:

```swift
func testMap_Range() {
        // Initializes test scheduler.
        // Test scheduler implements virtual time that is
        // detached from local machine clock.
        // This enables running the simulation as fast as possible
        // and proving that all events have been handled.
        let scheduler = TestScheduler(initialClock: 0)

        // Creates a mock hot observable sequence.
        // The sequence will emit events at desginated
        // times, no matter if there are observers subscribed or not.
        // (that's what hot means).
        // This observable sequence will also record all subscriptions
        // made during its lifetime (`subscriptions` property).
        let xs = scheduler.createHotObservable([
            next(150, 1),  // first argument is virtual time, second argument is element value
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300) // virtual time when completed is sent
            ])

        // `start` method will by default:
        // * Run the simulation and record all events
        //   using observer referenced by `res`.
        // * Subscribe at virtual time 200
        // * Dispose subscription at virtual time 1000
        let res = scheduler.start { xs.map { $0 * 2 } }

        let correctMessages = [
            next(210, 0 * 2),
            next(220, 1 * 2),
            next(230, 2 * 2),
            next(240, 4 * 2),
            completed(300)
        ]

        let correctSubscriptions = [
            Subscription(200, 300)
        ]

        XCTAssertEqual(res.events, correctMessages)
        XCTAssertEqual(xs.subscriptions, correctSubscriptions)
    }
```

## Testing operator compositions (view models, components)

Examples of how to test operator compositions are contained inside `Rx.xcworkspace` > `RxExample-iOSTests` target.

It's easy to define `RxTests` extensions so you can write your tests in a readable way. Provided examples inside `RxExample-iOSTests` are just suggestions on how you can write those extensions, but there are a lot of possibilities on how to write those tests.

```swift
    // expected events and test data
    let (
        usernameEvents,
        passwordEvents,
        repeatedPasswordEvents,
        loginTapEvents,

        expectedValidatedUsernameEvents,
        expectedSignupEnabledEvents
    ) = (
        scheduler.parseEventsAndTimes("e---u1----u2-----u3-----------------", values: stringValues).first!,
        scheduler.parseEventsAndTimes("e----------------------p1-----------", values: stringValues).first!,
        scheduler.parseEventsAndTimes("e---------------------------p2---p1-", values: stringValues).first!,
        scheduler.parseEventsAndTimes("------------------------------------", values: events).first!,

        scheduler.parseEventsAndTimes("e---v--f--v--f---v--o----------------", values: validations).first!,
        scheduler.parseEventsAndTimes("f--------------------------------t---", values: booleans).first!
    )
```

## Integration tests

It is also possible to write integration tests by using `RxBlocking` operators.

Importing operators from `RxBlocking` library will enable blocking the current thread and wait for sequence results.

```swift
let result = try fetchResource(location)
        .toBlocking()
        .toArray()

XCTAssertEqual(result, expectedResult)
```
