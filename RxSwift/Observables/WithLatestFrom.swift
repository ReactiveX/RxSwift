//
//  WithLatestFrom.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Merges two observable sequences into one observable sequence by combining each element from self with the latest element from the second source, if any.

     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     - note: Elements emitted by self before the second source has emitted any values will be omitted.

     - parameter second: Second observable source.
     - parameter resultSelector: Function to invoke for each element from the self combined with the latest element from the second source, if any.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    func withLatestFrom<Source: ObservableConvertibleType, ResultType>(_ second: Source, resultSelector: @escaping (Element, Source.Element) throws -> ResultType) -> Observable<ResultType> {
        WithLatestFrom(first: asObservable(), second: second.asObservable(), resultSelector: resultSelector)
    }

    /**
     Merges two observable sequences into one observable sequence by using latest element from the second sequence every time when `self` emits an element.

     - seealso: [combineLatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)
     - note: Elements emitted by self before the second source has emitted any values will be omitted.

     - parameter second: Second observable source.
     - returns: An observable sequence containing the result of combining each element of the self  with the latest element from the second source, if any, using the specified result selector function.
     */
    func withLatestFrom<Source: ObservableConvertibleType>(_ second: Source) -> Observable<Source.Element> {
        WithLatestFrom(first: asObservable(), second: second.asObservable(), resultSelector: { $1 })
    }
}

private final class WithLatestFromSink<FirstType, SecondType, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias ResultType = Observer.Element
    typealias Parent = WithLatestFrom<FirstType, SecondType, ResultType>
    typealias Element = FirstType

    private let parent: Parent

    fileprivate var lock = RecursiveLock()
    fileprivate var latest: SecondType?

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent

        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        let sndSubscription = SingleAssignmentDisposable()
        let sndO = WithLatestFromSecond(parent: self, disposable: sndSubscription)

        sndSubscription.setDisposable(parent.second.subscribe(sndO))
        let fstSubscription = parent.first.subscribe(self)

        return Disposables.create(fstSubscription, sndSubscription)
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            guard let latest else { return }
            do {
                let res = try parent.resultSelector(value, latest)

                forwardOn(.next(res))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .completed:
            forwardOn(.completed)
            dispose()
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        }
    }
}

private final class WithLatestFromSecond<FirstType, SecondType, Observer: ObserverType>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias ResultType = Observer.Element
    typealias Parent = WithLatestFromSink<FirstType, SecondType, Observer>
    typealias Element = SecondType

    private let parent: Parent
    private let disposable: Disposable

    var lock: RecursiveLock {
        parent.lock
    }

    init(parent: Parent, disposable: Disposable) {
        self.parent = parent
        self.disposable = disposable
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            parent.latest = value
        case .completed:
            disposable.dispose()
        case let .error(error):
            parent.forwardOn(.error(error))
            parent.dispose()
        }
    }
}

private final class WithLatestFrom<FirstType, SecondType, ResultType>: Producer<ResultType> {
    typealias ResultSelector = (FirstType, SecondType) throws -> ResultType

    fileprivate let first: Observable<FirstType>
    fileprivate let second: Observable<SecondType>
    fileprivate let resultSelector: ResultSelector

    init(first: Observable<FirstType>, second: Observable<SecondType>, resultSelector: @escaping ResultSelector) {
        self.first = first
        self.second = second
        self.resultSelector = resultSelector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == ResultType {
        let sink = WithLatestFromSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
