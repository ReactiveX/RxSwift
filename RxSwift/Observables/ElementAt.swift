//
//  ElementAt.swift
//  RxSwift
//
//  Created by Junior B. on 21/10/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Returns a sequence emitting only element _n_ emitted by an Observable

     - seealso: [elementAt operator on reactivex.io](http://reactivex.io/documentation/operators/elementat.html)

     - parameter index: The index of the required element (starting from 0).
     - returns: An observable sequence that emits the desired element as its own sole emission.
     */
    @available(*, deprecated, renamed: "element(at:)")
    func elementAt(_ index: Int)
        -> Observable<Element>
    {
        element(at: index)
    }

    /**
     Returns a sequence emitting only element _n_ emitted by an Observable

     - seealso: [elementAt operator on reactivex.io](http://reactivex.io/documentation/operators/elementat.html)

     - parameter index: The index of the required element (starting from 0).
     - returns: An observable sequence that emits the desired element as its own sole emission.
     */
    func element(at index: Int)
        -> Observable<Element>
    {
        ElementAt(source: asObservable(), index: index, throwOnEmpty: true)
    }
}

private final class ElementAtSink<Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias SourceType = Observer.Element
    typealias Parent = ElementAt<SourceType>

    let parent: Parent
    var i: Int

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        i = parent.index

        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case .next:
            if i == 0 {
                forwardOn(event)
                forwardOn(.completed)
                dispose()
            }

            do {
                _ = try decrementChecked(&i)
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
                return
            }

        case let .error(e):
            forwardOn(.error(e))
            dispose()

        case .completed:
            if parent.throwOnEmpty {
                forwardOn(.error(RxError.argumentOutOfRange))
            } else {
                forwardOn(.completed)
            }

            dispose()
        }
    }
}

private final class ElementAt<SourceType>: Producer<SourceType> {
    let source: Observable<SourceType>
    let throwOnEmpty: Bool
    let index: Int

    init(source: Observable<SourceType>, index: Int, throwOnEmpty: Bool) {
        if index < 0 {
            rxFatalError("index can't be negative")
        }

        self.source = source
        self.index = index
        self.throwOnEmpty = throwOnEmpty
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == SourceType {
        let sink = ElementAtSink(parent: self, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
