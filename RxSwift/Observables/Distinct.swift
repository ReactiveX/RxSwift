//
//  Distinct.swift
//  RxSwift-iOS
//
//  Created by Siarhei Fedartsou on 11/22/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

extension ObservableType where E: Hashable {
    /**
     Returns an observable sequence that contains only distinct elements according to equality operator. Elements of source must conform to Hashable protocol.
     
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     
     - returns: An observable sequence only containing the distinct elements, based on equality operator, from the source sequence.
     */
    public func distinct()
        -> Observable<E> {
            return distinct { $0 }
    }
}

extension ObservableType {
    /**
     Returns an observable sequence that contains only distinct elements according to the `keySelector`.
     
     - seealso: [distinct operator on reactivex.io](http://reactivex.io/documentation/operators/distinct.html)
     
     - parameter keySelector: A function to compute key by which elements distinction is decided. Returned key must conform to Hashable protocol.
     - returns: An observable sequence only containing the distinct elements, based on a computed key value, from the source sequence.
     */
    public func distinct<T: Hashable>(_ keySelector: @escaping (E) throws -> T)
        -> Observable<E> {
            return Distinct(source: self.asObservable(), selector: keySelector)
    }
}


final fileprivate class DistinctSink<O: ObserverType, Key: Hashable>: Sink<O>, ObserverType {
    typealias E = O.E
    
    private let _parent: Distinct<E, Key>
    private var _seen = Set<Key>()
    
    init(parent: Distinct<E, Key>, observer: O, cancel: Cancelable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<E>) {
        switch event {
        case .next(let value):
            do {
                let key = try _parent._selector(value)
                guard !_seen.contains(key) else {
                    return
                }
                
                _seen.insert(key)
                
                forwardOn(event)
            }
            catch let error {
                forwardOn(.error(error))
                dispose()
            }
        case .error, .completed:
            forwardOn(event)
            dispose()
        }
    }
}

final fileprivate class Distinct<Element, Key: Hashable>: Producer<Element> {
    typealias KeySelector = (Element) throws -> Key
    
    fileprivate let _source: Observable<Element>
    fileprivate let _selector: KeySelector
    
    init(source: Observable<Element>, selector: @escaping KeySelector) {
        _source = source
        _selector = selector
    }
    
    override func run<O: ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == Element {
        let sink = DistinctSink(parent: self, observer: observer, cancel: cancel)
        let subscription = _source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
