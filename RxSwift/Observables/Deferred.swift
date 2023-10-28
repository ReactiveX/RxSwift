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
    public static func deferred(_ observableFactory: @escaping () throws -> Observable<Element>)
        -> Observable<Element> {
        Deferred(observableFactory: observableFactory)
    }
}

final private class DeferredSink<Source: ObservableType, Observer: ObserverType>: Sink<Observer>, ObserverType where Source.Element == Observer.Element {
    typealias Element = Observer.Element
    typealias Parent = Deferred<Source>
    
    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(_ parent: Parent) -> Disposable {
        do {
            let result = try parent.observableFactory()
            return result.subscribe(self)
        }
        catch let e {
            self.forwardOn(.error(e))
            self.dispose()
            return Disposables.create()
        }
    }
    
    func on(_ event: Event<Element>) {
        self.forwardOn(event)
        
        switch event {
        case .next:
            break
        case .error:
            self.dispose()
        case .completed:
            self.dispose()
        }
    }
}

final private class Deferred<Source: ObservableType>: Producer<Source.Element> {
    typealias Factory = () throws -> Source
    
    let observableFactory : Factory
    
    init(observableFactory: @escaping Factory) {
        self.observableFactory = observableFactory
    }
    
    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable)
             where Observer.Element == Source.Element {
        let sink = DeferredSink<Source, Observer>(observer: observer, cancel: cancel)
        let subscription = sink.run(self)
        return (sink: sink, subscription: subscription)
    }
}
