//
//  Switch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func flatMapLatest<Source: ObservableConvertibleType>(_ selector: @escaping (Element) throws -> Source)
        -> Observable<Source.Element>
    {
        FlatMapLatest(source: asObservable(), selector: selector)
    }

    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func flatMapLatest<Source: InfallibleType>(_ selector: @escaping (Element) throws -> Source)
        -> Infallible<Source.Element>
    {
        Infallible(flatMapLatest(selector))
    }
}

public extension ObservableType where Element: ObservableConvertibleType {
    /**
     Transforms an observable sequence of observable sequences into an observable sequence
     producing values only from the most recent observable sequence.

     Each time a new inner observable sequence is received, unsubscribe from the
     previous inner observable sequence.

     - seealso: [switch operator on reactivex.io](http://reactivex.io/documentation/operators/switch.html)

     - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    func switchLatest() -> Observable<Element.Element> {
        Switch(source: asObservable())
    }
}

private class SwitchSink<SourceType, Source: ObservableConvertibleType, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType where Source.Element == Observer.Element
{
    typealias Element = SourceType

    private let subscriptions: SingleAssignmentDisposable = .init()
    private let innerSubscription: SerialDisposable = .init()

    let lock = RecursiveLock()

    // state
    fileprivate var stopped = false
    fileprivate var latest = 0
    fileprivate var hasLatest = false

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func run(_ source: Observable<SourceType>) -> Disposable {
        let subscription = source.subscribe(self)
        subscriptions.setDisposable(subscription)
        return Disposables.create(subscriptions, innerSubscription)
    }

    func performMap(_: SourceType) throws -> Source {
        rxAbstractMethod()
    }

    @inline(__always)
    private final func nextElementArrived(element: Element) -> (Int, Observable<Source.Element>)? {
        lock.lock(); defer { self.lock.unlock() }

        do {
            let observable = try performMap(element).asObservable()
            hasLatest = true
            latest = latest &+ 1
            return (latest, observable)
        } catch {
            forwardOn(.error(error))
            dispose()
        }

        return nil
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(element):
            if let (latest, observable) = nextElementArrived(element: element) {
                let d = SingleAssignmentDisposable()
                innerSubscription.disposable = d

                let observer = SwitchSinkIter(parent: self, id: latest, this: d)
                let disposable = observable.subscribe(observer)
                d.setDisposable(disposable)
            }
        case let .error(error):
            lock.lock(); defer { self.lock.unlock() }
            forwardOn(.error(error))
            dispose()
        case .completed:
            lock.lock(); defer { self.lock.unlock() }
            stopped = true

            subscriptions.dispose()

            if !hasLatest {
                forwardOn(.completed)
                dispose()
            }
        }
    }
}

private final class SwitchSinkIter<SourceType, Source: ObservableConvertibleType, Observer: ObserverType>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType where Source.Element == Observer.Element
{
    typealias Element = Source.Element
    typealias Parent = SwitchSink<SourceType, Source, Observer>

    private let parent: Parent
    private let id: Int
    private let this: Disposable

    var lock: RecursiveLock {
        parent.lock
    }

    init(parent: Parent, id: Int, this: Disposable) {
        self.parent = parent
        self.id = id
        self.this = this
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case .next: break
        case .error, .completed:
            this.dispose()
        }

        if parent.latest != id {
            return
        }

        switch event {
        case .next:
            parent.forwardOn(event)
        case .error:
            parent.forwardOn(event)
            parent.dispose()
        case .completed:
            parent.hasLatest = false
            if parent.stopped {
                parent.forwardOn(event)
                parent.dispose()
            }
        }
    }
}

// MARK: Specializations

private final class SwitchIdentitySink<Source: ObservableConvertibleType, Observer: ObserverType>: SwitchSink<Source, Source, Observer>
    where Observer.Element == Source.Element
{
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: Source) throws -> Source {
        element
    }
}

private final class MapSwitchSink<SourceType, Source: ObservableConvertibleType, Observer: ObserverType>: SwitchSink<SourceType, Source, Observer> where Observer.Element == Source.Element {
    typealias Selector = (SourceType) throws -> Source

    private let selector: Selector

    init(selector: @escaping Selector, observer: Observer, cancel: Cancelable) {
        self.selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceType) throws -> Source {
        try selector(element)
    }
}

// MARK: Producers

private final class Switch<Source: ObservableConvertibleType>: Producer<Source.Element> {
    private let source: Observable<Source>

    init(source: Observable<Source>) {
        self.source = source
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Source.Element {
        let sink = SwitchIdentitySink<Source, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}

private final class FlatMapLatest<SourceType, Source: ObservableConvertibleType>: Producer<Source.Element> {
    typealias Selector = (SourceType) throws -> Source

    private let source: Observable<SourceType>
    private let selector: Selector

    init(source: Observable<SourceType>, selector: @escaping Selector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Source.Element {
        let sink = MapSwitchSink<SourceType, Source, Observer>(selector: selector, observer: observer, cancel: cancel)
        let subscription = sink.run(source)
        return (sink: sink, subscription: subscription)
    }
}
