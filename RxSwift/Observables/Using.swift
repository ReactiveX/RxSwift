//
//  Using.swift
//  RxSwift
//
//  Created by Yury Korolev on 10/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Constructs an observable sequence that depends on a resource object, whose lifetime is tied to the resulting observable sequence's lifetime.

     - seealso: [using operator on reactivex.io](http://reactivex.io/documentation/operators/using.html)

     - parameter resourceFactory: Factory function to obtain a resource object.
     - parameter observableFactory: Factory function to obtain an observable sequence that depends on the obtained resource.
     - returns: An observable sequence whose lifetime controls the lifetime of the dependent resource object.
     */
    static func using<Resource: Disposable>(_ resourceFactory: @escaping () throws -> Resource, observableFactory: @escaping (Resource) throws -> Observable<Element>) -> Observable<Element> {
        Using(resourceFactory: resourceFactory, observableFactory: observableFactory)
    }
}

private final class UsingSink<ResourceType: Disposable, Observer: ObserverType>: Sink<Observer>, ObserverType {
    typealias SourceType = Observer.Element
    typealias Parent = Using<SourceType, ResourceType>

    private let parent: Parent

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        var disposable = Disposables.create()

        do {
            let resource = try parent.resourceFactory()
            disposable = resource
            let source = try parent.observableFactory(resource)

            return Disposables.create(
                source.subscribe(self),
                disposable
            )
        } catch {
            return Disposables.create(
                Observable.error(error).subscribe(self),
                disposable
            )
        }
    }

    func on(_ event: Event<SourceType>) {
        switch event {
        case let .next(value):
            forwardOn(.next(value))
        case let .error(error):
            forwardOn(.error(error))
            dispose()
        case .completed:
            forwardOn(.completed)
            dispose()
        }
    }
}

private final class Using<SourceType, ResourceType: Disposable>: Producer<SourceType> {
    typealias Element = SourceType

    typealias ResourceFactory = () throws -> ResourceType
    typealias ObservableFactory = (ResourceType) throws -> Observable<SourceType>

    fileprivate let resourceFactory: ResourceFactory
    fileprivate let observableFactory: ObservableFactory

    init(resourceFactory: @escaping ResourceFactory, observableFactory: @escaping ObservableFactory) {
        self.resourceFactory = resourceFactory
        self.observableFactory = observableFactory
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Element {
        let sink = UsingSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
