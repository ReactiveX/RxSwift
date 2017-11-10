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
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control: Equatable, Event>(
        query: @escaping (State) -> Control?,
        effects: @escaping (Control) -> Observable<Event>
    ) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 == $1 }
            .flatMapLatest { (control: Control?) -> Observable<Event> in
                guard let control = control else {
                    return Observable<Event>.empty()
                }

                return effects(control)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control: Equatable, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Signal<Event>
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
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Observable<Event>
) -> (ObservableSchedulerContext<State>) -> Observable<Event> {
    return { state in
        return state.map(query)
            .distinctUntilChanged { $0 != nil }
            .flatMapLatest { (control: Control?) -> Observable<Event> in
                guard let control = control else {
                    return Observable<Event>.empty()
                }

                return effects(control)
                    .enqueue(state.scheduler)
        }
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Control?,
    effects: @escaping (Control) -> Signal<Event>
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
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Set<Control>,
    effects: @escaping (Control) -> Observable<Event>
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
    fileprivate func takeUntilWithCompletedAsync<O>(_ other: Observable<O>, scheduler: ImmediateSchedulerType) -> Observable<E> {
            // this little piggy will delay completed event
            let completeAsSoonAsPossible = Observable<E>.empty().observeOn(scheduler)
            return other
                .take(1)
                .map { _ in completeAsSoonAsPossible }
                // this little piggy will ensure self is being run first
                .startWith(self.asObservable())
                // this little piggy will ensure that new events are being blocked immediatelly
                .switchLatest()
    }
}

/**
 Control feedback loop that tries to immediatelly perform the latest required effect.

 * State: State type of the system.
 * Control: Subset of state used to control the feedback loop.

 When query result exists (not `nil`), feedback loop is active and it performs effects.

 When query result is `nil`, feedback loops doesn't perform any effect.

 - parameter query: State type of the system
 - parameter effects: Control state which is subset of state.
 - returns: Feedback loop performing the effects.
 */
public func react<State, Control, Event>(
    query: @escaping (State) -> Set<Control>,
    effects: @escaping (Control) -> Signal<Event>
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
            // (smooths out any glitches caused by start-cancel immediatelly)
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
