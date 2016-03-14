Unit Tests
==========

## Testing custom operators

Library uses `RxTests` for all of RxSwift operator tests so you can take a look at AllTests-* target inside the project `Rx.xcworkspace`.

This is an example of a typical `RxSwift` operator unit test:

```swift
func testMap_Range() {
        // Initializes test scheduler.
        // Test scheduler implements virtual time that is
        // detached from local machine clock.
        // That enables running the simulation as fast as possible
        // and proving that all events have been handled.
        let scheduler = TestScheduler(initialClock: 0)

        // Creates a mock hot observable sequence.
        // The sequence will emit events at following
        // times no matter is there some observer subscribed.
        // (that's what hot means).
        // This observable sequence will also record all subscriptions
        // made during it's lifetime (`subscriptions` property).
        let xs = scheduler.createHotObservable([
            next(150, 1),  // first argument is virtual time, second argument is element value
            next(210, 0),
            next(220, 1),
            next(230, 2),
            next(240, 4),
            completed(300) // virtual time when completed is sent
            ])

        // `start` method will by default:
        // * run the simulation and record all events
        //   using observer referenced by `res`.
        // * subscribe at virtual time 200
        // * dispose subscription at virtual time 1000
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

Examples how to test operator compositions are contained inside `Rx.xcworkspace` > `RxExample-iOSTests` target.

It easy to define `RxTests` extensions so you can write your tests in a readable way. Provided examples inside `RxExample-iOSTests` are just a tip how you can write those extensions, but there is a lot of possibilities how to write those tests.

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
