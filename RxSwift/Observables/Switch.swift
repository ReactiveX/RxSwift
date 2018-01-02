//
//  Switch.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Projects each element of an observable sequence into a new sequence of observable sequences and then
     transforms an observable sequence of observable sequences into an observable sequence producing values only from the most recent observable sequence.

     It is a combination of `map` + `switchLatest` operator

     - seealso: [flatMapLatest operator on reactivex.io](http://reactivex.io/documentation/operators/flatmap.html)

     - parameter selector: A transform function to apply to each element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source producing an
     Observable of Observable sequences and that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func flatMapLatest<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O)
        -> Observable<O.E> {
            return FlatMapLatest(source: asObservable(), selector: selector)
    }
}

extension ObservableType where E : ObservableConvertibleType {

    /**
     Transforms an observable sequence of observable sequences into an observable sequence
     producing values only from the most recent observable sequence.

     Each time a new inner observable sequence is received, unsubscribe from the
     previous inner observable sequence.

     - seealso: [switch operator on reactivex.io](http://reactivex.io/documentation/operators/switch.html)

     - returns: The observable sequence that at any point in time produces the elements of the most recent inner observable sequence that has been received.
     */
    public func switchLatest() -> Observable<E.E> {
        return Switch(source: asObservable())
    }
}

fileprivate class SwitchSink<SourceType, S: ObservableConvertibleType>
    : Sink<S.E> {
    typealias E = SourceType

    fileprivate let _subscriptions: SingleAssignmentDisposable = SingleAssignmentDisposable()
    fileprivate let _innerSubscription: SerialDisposable = SerialDisposable()

    let _lock = RecursiveLock()
    
    // state
    fileprivate var _stopped = false
    fileprivate var _latest = 0
    fileprivate var _hasLatest = false
    
    func run(_ source: Observable<SourceType>) -> Disposable {
        let subscription = source.subscribe(Observer { event in
            switch event {
            case .next(let element):
                if let (latest, observable) = self.nextElementArrived(element: element) {
                    let d = SingleAssignmentDisposable()
                    self._innerSubscription.disposable = d

                    let disposable = observable.subscribe(Observer { event in
                        self._lock.lock(); defer { self._lock.unlock() } // {
                        switch event {
                        case .next: break
                        case .error, .completed:
                            d.dispose()
                        }

                        if self._latest != latest {
                            return
                        }

                        switch event {
                        case .next:
                            self.forwardOn(event)
                        case .error:
                            self.forwardOn(event)
                            self.dispose()
                        case .completed:
                            self._hasLatest = false
                            if self._stopped {
                                self.forwardOn(event)
                                self.dispose()
                            }
                        }
                    })
                    d.setDisposable(disposable)
                }
            case .error(let error):
                self._lock.lock(); defer { self._lock.unlock() }
                self.forwardOn(.error(error))
                self.dispose()
            case .completed:
                self._lock.lock(); defer { self._lock.unlock() }
                self._stopped = true

                self._subscriptions.dispose()

                if !self._hasLatest {
                    self.forwardOn(.completed)
                    self.dispose()
                }
            }
        })
        _subscriptions.setDisposable(subscription)
        return Disposables.create(_subscriptions, _innerSubscription)
    }

    func performMap(_ element: SourceType) throws -> S {
        rxAbstractMethod()
    }

    @inline(__always)
    final private func nextElementArrived(element: E) -> (Int, Observable<S.E>)? {
        _lock.lock(); defer { _lock.unlock() } // {
            do {
                let observable = try performMap(element).asObservable()
                _hasLatest = true
                _latest = _latest &+ 1
                return (_latest, observable)
            }
            catch let error {
                forwardOn(.error(error))
                dispose()
            }

            return nil
        // }
    }
}

// MARK: Specializations

final fileprivate class SwitchIdentitySink<S: ObservableConvertibleType> : SwitchSink<S, S> {
    override func performMap(_ element: S) throws -> S {
        return element
    }
}

final fileprivate class MapSwitchSink<SourceType, S: ObservableConvertibleType> : SwitchSink<SourceType, S> {
    typealias Selector = (SourceType) throws -> S

    fileprivate let _selector: Selector

    init(selector: @escaping Selector, observer: Observer<S.E>, cancel: Cancelable) {
        _selector = selector
        super.init(observer: observer, cancel: cancel)
    }

    override func performMap(_ element: SourceType) throws -> S {
        return try _selector(element)
    }
}

// MARK: Producers

final fileprivate class Switch<S: ObservableConvertibleType> : Producer<S.E> {
    fileprivate let _source: Observable<S>
    
    init(source: Observable<S>) {
        _source = source
    }
    
    override func run(_ observer: Observer<S.E>, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = SwitchIdentitySink<S>(observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}

final fileprivate class FlatMapLatest<SourceType, S: ObservableConvertibleType> : Producer<S.E> {
    typealias Selector = (SourceType) throws -> S

    fileprivate let _source: Observable<SourceType>
    fileprivate let _selector: Selector

    init(source: Observable<SourceType>, selector: @escaping Selector) {
        _source = source
        _selector = selector
    }

    override func run(_ observer: Observer<S.E>, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = MapSwitchSink<SourceType, S>(selector: _selector, observer: observer, cancel: cancel)
        let subscription = sink.run(_source)
        return (sink: sink, subscription: subscription)
    }
}
