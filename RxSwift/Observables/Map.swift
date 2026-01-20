//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    func map<Result>(_ transform: @escaping (Element) throws -> Result)
        -> Observable<Result>
    {
        Map(source: asObservable(), transform: transform)
    }
}

private final class MapSink<SourceType, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias Transform = (SourceType) throws -> ResultType

    typealias ResultType = Observer.Element

    private let transform: Transform

    init(transform: @escaping Transform, observer: Observer, cancel: Cancelable) {
        self.transform = transform
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case let .next(element):
            do {
                let mappedElement = try transform(element)
                forwardOn(.next(mappedElement))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

private final class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let source: Observable<SourceType>

    private let transform: Transform

    init(source: Observable<SourceType>, transform: @escaping Transform) {
        self.source = source
        self.transform = transform
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == ResultType {
        let sink = MapSink(transform: transform, observer: observer, cancel: cancel)
        let subscription = source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
