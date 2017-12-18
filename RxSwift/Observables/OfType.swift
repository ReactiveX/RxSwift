//
//  OfType.swift
//  Rx
//
//  Created by Nate Kim on 18/12/2017.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    
    /**
     Filters the elements of an observable sequence, if that is an instance of the supplied type.
     
     - seealso: [filter operator on reactivex.io](http://reactivex.io/documentation/operators/filter.html)
     
     - parameter type: The Type to filter each source element.
     - returns: An observable sequence that contains elements which is an instance of the suppplied type.
     */
    public func ofType<T>(_ type:T.Type) -> Observable<T> {
        return OfType(source: asObservable(), type: type)
    }
}

final fileprivate class OfTypeSink<SourceType, ResultType, O : ObserverType>: Sink<O>, ObserverType where O.E == ResultType {

    typealias Element = SourceType
    
    func on(_ event: Event<Element>) {
        switch event {
        case .next(let value):
            if let satisfies = value as? ResultType {
                forwardOn(.next(satisfies))
            }
        case .error(let error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

final fileprivate class OfType<SourceType, ResultType> : Producer<ResultType> {
    
    private let _source: Observable<SourceType>
    
    init(source: Observable<SourceType>, type: ResultType.Type) {
        _source = source
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == ResultType {
        let sink = OfTypeSink<SourceType, ResultType, O>(observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}

