//
//  Map.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {

    /**
     Projects each element of an observable sequence into a new form.

     - seealso: [map operator on reactivex.io](http://reactivex.io/documentation/operators/map.html)

     - parameter transform: A transform function to apply to each source element.
     - returns: An observable sequence whose elements are the result of invoking the transform function on each element of source.

     */
    public func map<R>(_ transform: @escaping (E) throws -> R)
        -> Observable<R> {
        return self.asObservable().composeMap(transform)
    }
}

#if TRACE_RESOURCES
    fileprivate var _numberOfMapOperators: AtomicInt = 0
    extension Resources {
        public static var numberOfMapOperators: Int32 {
            return _numberOfMapOperators.valueSnapshot()
        }
    }
#endif

internal func _map<Element, R>(source: Observable<Element>, transform: @escaping (Element) throws -> R) -> Observable<R> {
    return Map(source: source, transform: transform)
}

final fileprivate class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Transform = (SourceType) throws -> ResultType

    private let _source: Observable<SourceType>

    private let _transform: Transform

    init(source: Observable<SourceType>, transform: @escaping Transform) {
        _source = source
        _transform = transform

#if TRACE_RESOURCES
        let _ = AtomicIncrement(&_numberOfMapOperators)
#endif
    }

    override func composeMap<R>(_ selector: @escaping (ResultType) throws -> R) -> Observable<R> {
        let originalSelector = _transform
        return Map<SourceType, R>(source: _source, transform: { (s: SourceType) throws -> R in
            let r: ResultType = try originalSelector(s)
            return try selector(r)
        })
    }
    
    override func run(_ observer: @escaping (Event<ResultType>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = _source.subscribe { event in
            switch event {
            case .next(let element):
                do {
                    let mappedElement = try self._transform(element)
                    sink.forwardOn(.next(mappedElement))
                }
                catch let e {
                    sink.forwardOn(.error(e))
                    sink.dispose()
                }
            case .error(let error):
                sink.forwardOn(.error(error))
                sink.dispose()
            case .completed:
                sink.forwardOn(.completed)
                sink.dispose()
            }
        }
        return (sink: sink, subscription: subscription)
    }

    #if TRACE_RESOURCES
    deinit {
        let _ = AtomicDecrement(&_numberOfMapOperators)
    }
    #endif
}
