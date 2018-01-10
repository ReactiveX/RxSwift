//
//  Deferred.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension ObservableType {
    /**
     Returns an observable sequence that invokes the specified factory function whenever a new observer subscribes.

     - seealso: [defer operator on reactivex.io](http://reactivex.io/documentation/operators/defer.html)

     - parameter observableFactory: Observable factory function to invoke for each observer that subscribes to the resulting sequence.
     - returns: An observable sequence whose observers trigger an invocation of the given observable factory function.
     */
    public static func deferred(_ observableFactory: @escaping () throws -> Observable<E>)
        -> Observable<E> {
        return Deferred(observableFactory: observableFactory)
    }
}

final fileprivate class Deferred<S: ObservableType> : Producer<S.E> {
    typealias Factory = () throws -> S
    
    private let _observableFactory : Factory
    
    init(observableFactory: @escaping Factory) {
        _observableFactory = observableFactory
    }
    
    override func run(_ observer: @escaping (Event<E>) -> (), cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) {
        let sink = Sink(observer: observer, cancel: cancel)
        let subscription = { () -> Disposable in
                do {
                    let result = try _observableFactory()
                    return result.subscribe { event in
                        sink.forwardOn(event)

                        switch event {
                        case .next:
                            break
                        case .error:
                            sink.dispose()
                        case .completed:
                            sink.dispose()
                        }
                    }
                }
                catch let e {
                    sink.forwardOn(.error(e))
                    sink.dispose()
                    return Disposable.create()
                }
        }()
        return (sink: sink, subscription: subscription)
    }
}
