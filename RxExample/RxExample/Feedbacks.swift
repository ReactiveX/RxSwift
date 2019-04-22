//
//  Feedbacks.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 5/1/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxCocoa

// Taken from RxFeedback repo

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter areEqual: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Query?,
    areEqual: @escaping (Query, Query) -> Bool,
    effects: @escaping (Query) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { lhs, rhs in
                switch (lhs, rhs) {
                case (.none, .none): return true
                case (.none, .some): return false
                case (.some, .none): return false
                case (.some(let lhs), .some(let rhs)): return areEqual(lhs, rhs)
                }
            }
            .flatMapLatest { (control: Query?) -> Observable<Event> in
                guard let control = control else {
                    return Observable<Event>.empty()
                }

                return effects(control)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query: Equatable, Event>(
    query: @escaping (State) -> Query?,
    effects: @escaping (Query) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return react(query: query, areEqual: { $0 == $1 }, effects: effects)
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter areEqual: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Query?,
    areEqual: @escaping (Query, Query) -> Bool,
    effects: @escaping (Query) -> Signal<Event>
    ) -> (Driver<State>) -> Signal<Event> {
    return { state in
        let observableSchedulerContext = ObservableSchedulerContext<State>(
            source: state.asObservable(),
            scheduler: Signal<Event>.SharingStrategy.scheduler.async
        )
        return react(query: query, areEqual: areEqual, effects: { effects($0).asObservable() })(observableSchedulerContext)
            .asSignal(onErrorSignalWith: .empty())
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query: Equatable, Event>(
    query: @escaping (State) -> Query?,
    effects: @escaping (Query) -> Signal<Event>
    ) -> (Driver<State>) -> Signal<Event> {
    return { state in
        let observableSchedulerContext = ObservableSchedulerContext<State>(
            source: state.asObservable(),
            scheduler: Signal<Event>.SharingStrategy.scheduler.async
        )
        return react(query: query, effects: { effects($0).asObservable() })(observableSchedulerContext)
            .asSignal(onErrorSignalWith: .empty())
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Query?,
    effects: @escaping (Query) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 != nil }
            .flatMapLatest { (control: Query?) -> Observable<Event> in
                guard let control = control else {
                    return Observable<Event>.empty()
                }

                return effects(control)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns a value, that value is being passed into `effects` lambda to decide which effects should be performed.
 In case new `query` is different from the previous one, new effects are calculated by using `effects` lambda and then performed.

 When `query` returns `nil`, feedback loops doesn't perform any effect.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query result.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Query?,
    effects: @escaping (Query) -> Signal<Event>
    ) -> (Driver<State>) -> Signal<Event> {
    return { state in
        let observableSchedulerContext = ObservableSchedulerContext<State>(
            source: state.asObservable(),
            scheduler: Signal<Event>.SharingStrategy.scheduler.async
        )
        return react(query: query, effects: { effects($0).asObservable() })(observableSchedulerContext)
            .asSignal(onErrorSignalWith: .empty())
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns some set of values, each value is being passed into `effects` lambda to decide which effects should be performed.

 * Effects are not interrupted for elements in the new `query` that were present in the `old` query.
 * Effects are cancelled for elements present in `old` query but not in `new` query.
 * In case new elements are present in `new` query (and not in `old` query) they are being passed to the `effects` lambda and resulting effects are being performed.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query element.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Set<Query>,
    effects: @escaping (Query) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        let query = state.map(query)
            .share(replay: 1)

        let newQueries = Observable.zip(query, query.startWith(Set())) { $0.subtracting($1) }
        let asyncScheduler = state.scheduler.async

        return newQueries.flatMap { controls in
            return Observable<Event>.merge(controls.map { control -> Observable<Event> in
                return effects(control)
                    .enqueue(state.scheduler)
                    .takeUntilWithCompletedAsync(query.filter { !$0.contains(control) }, scheduler: asyncScheduler)
            })
        }
    }
}

extension ObservableType {
    // This is important to avoid reentrancy issues. Completed event is only used for cleanup
    fileprivate func takeUntilWithCompletedAsync<O>(_ other: Observable<O>, scheduler: ImmediateSchedulerType) -> Observable<Element> {
        // this little piggy will delay completed event
        let completeAsSoonAsPossible = Observable<Element>.empty().observeOn(scheduler)
        return other
            .take(1)
            .map { _ in completeAsSoonAsPossible }
            // this little piggy will ensure self is being run first
            .startWith(self.asObservable())
            // this little piggy will ensure that new events are being blocked immediately
            .switchLatest()
    }
}

/**
 * State: State type of the system.
 * Query: Subset of state used to control the feedback loop.

 When `query` returns some set of values, each value is being passed into `effects` lambda to decide which effects should be performed.

 * Effects are not interrupted for elements in the new `query` that were present in the `old` query.
 * Effects are cancelled for elements present in `old` query but not in `new` query.
 * In case new elements are present in `new` query (and not in `old` query) they are being passed to the `effects` lambda and resulting effects are being performed.

 - parameter query: Part of state that controls feedback loop.
 - parameter effects: Chooses which effects to perform for certain query element.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Query, Event>(
    query: @escaping (State) -> Set<Query>,
    effects: @escaping (Query) -> Signal<Event>
    ) -> (Driver<State>) -> Signal<Event> {
    return { (state: Driver<State>) -> Signal<Event> in
        let observableSchedulerContext = ObservableSchedulerContext<State>(
            source: state.asObservable(),
            scheduler: Signal<Event>.SharingStrategy.scheduler.async
        )
        return react(query: query, effects: { effects($0).asObservable() })(observableSchedulerContext)
            .asSignal(onErrorSignalWith: .empty())
    }
}


extension Observable {
    fileprivate func enqueue(_ scheduler: ImmediateSchedulerType) -> Observable<Element> {
        return self
            // observe on is here because results should be cancelable
            .observeOn(scheduler.async)
            // subscribe on is here because side-effects also need to be cancelable
            // (smooths out any glitches caused by start-cancel immediately)
            .subscribeOn(scheduler.async)
    }
}

/**
 Contains subscriptions and events.
 - `subscriptions` map a system state to UI presentation.
 - `events` map events from UI to events of a given system.
 */
public class Bindings<Event>: Disposable {
    fileprivate let subscriptions: [Disposable]
    fileprivate let events: [Observable<Event>]

    /**
     - parameters:
     - subscriptions: mappings of a system state to UI presentation.
     - events: mappings of events from UI to events of a given system
     */
    public init(subscriptions: [Disposable], events: [Observable<Event>]) {
        self.subscriptions = subscriptions
        self.events = events
    }

    /**
     - parameters:
     - subscriptions: mappings of a system state to UI presentation.
     - events: mappings of events from UI to events of a given system
     */
    public init(subscriptions: [Disposable], events: [Signal<Event>]) {
        self.subscriptions = subscriptions
        self.events = events.map { $0.asObservable() }
    }

    public func dispose() {
        for subscription in subscriptions {
            subscription.dispose()
        }
    }
}

/**
 Bi-directional binding of a system State to external state machine and events from it.
 */
public func bind<State, Event>(_ bindings: @escaping (ObservableSchedulerContext<State>) -> (Bindings<Event>)) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { (state: ObservableSchedulerContext<State>) -> Observable<Event> in
        return Observable<Event>.using({ () -> Bindings<Event> in
            return bindings(state)
        }, observableFactory: { (bindings: Bindings<Event>) -> Observable<Event> in
            return Observable<Event>.merge(bindings.events)
                .enqueue(state.scheduler)
        })
    }
}

/**
 Bi-directional binding of a system State to external state machine and events from it.
 Strongify owner.
 */
public func bind<State, Event, WeakOwner>(_ owner: WeakOwner, _ bindings: @escaping (WeakOwner, ObservableSchedulerContext<State>) -> (Bindings<Event>))
    -> (ObservableSchedulerContext<State>) -> Observable<Event> where WeakOwner: AnyObject {
        return bind(bindingsStrongify(owner, bindings))
}

/**
 Bi-directional binding of a system State to external state machine and events from it.
 */
public func bind<State, Event>(_ bindings: @escaping (Driver<State>) -> (Bindings<Event>)) -> (Driver<State>) -> Signal<Event> {
    return { (state: Driver<State>) -> Signal<Event> in
        return Observable<Event>.using({ () -> Bindings<Event> in
            return bindings(state)
        }, observableFactory: { (bindings: Bindings<Event>) -> Observable<Event> in
            return Observable<Event>.merge(bindings.events)
        })
            .enqueue(Signal<Event>.SharingStrategy.scheduler)
            .asSignal(onErrorSignalWith: .empty())

    }
}

/**
 Bi-directional binding of a system State to external state machine and events from it.
 Strongify owner.
 */
public func bind<State, Event, WeakOwner>(_ owner: WeakOwner, _ bindings: @escaping (WeakOwner, Driver<State>) -> (Bindings<Event>))
    -> (Driver<State>) -> Signal<Event> where WeakOwner: AnyObject {
        return bind(bindingsStrongify(owner, bindings))
}

private func bindingsStrongify<Event, O, WeakOwner>(_ owner: WeakOwner, _ bindings: @escaping (WeakOwner, O) -> (Bindings<Event>))
    -> (O) -> (Bindings<Event>) where WeakOwner: AnyObject {
        return { [weak owner] state -> Bindings<Event> in
            guard let strongOwner = owner else {
                return Bindings(subscriptions: [], events: [Observable<Event>]())
            }
            return bindings(strongOwner, state)
        }
}

