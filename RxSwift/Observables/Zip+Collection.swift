//
//  Zip+Collection.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    static func zip<Collection: Swift.Collection>(_ collection: Collection, resultSelector: @escaping ([Collection.Element.Element]) throws -> Element) -> Observable<Element>
        where Collection.Element: ObservableType
    {
        ZipCollectionType(sources: collection, resultSelector: resultSelector)
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    static func zip<Collection: Swift.Collection>(_ collection: Collection) -> Observable<[Element]>
        where Collection.Element: ObservableType, Collection.Element.Element == Element
    {
        ZipCollectionType(sources: collection, resultSelector: { $0 })
    }
}

private final class ZipCollectionTypeSink<Collection: Swift.Collection, Observer: ObserverType>:
    Sink<Observer> where Collection.Element: ObservableConvertibleType
{
    typealias Result = Observer.Element
    typealias Parent = ZipCollectionType<Collection, Result>
    typealias SourceElement = Collection.Element.Element

    private struct Iterate: InvocableType {
        let action: () -> Void

        func invoke() {
            action()
        }
    }

    private enum CalloutAction {
        case none
        case disposeSubscription(SingleAssignmentDisposable)
        case evaluate([SourceElement])
        case forwardCompletedAndDispose
        case forwardErrorAndDispose(Swift.Error)
    }

    private let parent: Parent

    // Serialize event processing while keeping observer and disposal callouts out of `lock`.
    private let gate = AsyncLock<Iterate>()
    private let lock = RecursiveLock()

    // state
    private var isStopped = false
    private var numberOfValues = 0
    private var values: [Queue<SourceElement>]
    private var isDone: [Bool]
    private var numberOfDone = 0
    private var subscriptions: [SingleAssignmentDisposable]

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        values = [Queue<SourceElement>](repeating: Queue(capacity: 4), count: parent.count)
        isDone = [Bool](repeating: false, count: parent.count)
        subscriptions = [SingleAssignmentDisposable]()
        subscriptions.reserveCapacity(parent.count)

        for _ in 0 ..< parent.count {
            subscriptions.append(SingleAssignmentDisposable())
        }

        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceElement>, atIndex: Int) {
        gate.invoke(Iterate(action: { self.gated_on(event, atIndex: atIndex) }))
    }

    private func gated_on(_ event: Event<SourceElement>, atIndex: Int) {
        let action = lock.performLocked {
            nextAction(for: event, atIndex: atIndex)
        }

        perform(action)
    }

    private func nextAction(for event: Event<SourceElement>, atIndex: Int) -> CalloutAction {
        if isStopped || isDisposed {
            return .none
        }

        switch event {
        case let .next(element):
            values[atIndex].enqueue(element)

            if values[atIndex].count == 1 {
                numberOfValues += 1
            }

            if numberOfValues < parent.count {
                if numberOfDone == parent.count - 1 {
                    isStopped = true
                    return .forwardCompletedAndDispose
                }
                return .none
            }

            var arguments = [SourceElement]()
            arguments.reserveCapacity(parent.count)

            // recalculate number of values
            numberOfValues = 0

            for i in 0 ..< values.count {
                arguments.append(values[i].dequeue()!)
                if !values[i].isEmpty {
                    numberOfValues += 1
                }
            }

            return .evaluate(arguments)

        case let .error(error):
            isStopped = true
            return .forwardErrorAndDispose(error)

        case .completed:
            if isDone[atIndex] {
                return .none
            }

            isDone[atIndex] = true
            numberOfDone += 1

            if numberOfDone == parent.count {
                isStopped = true
                return .forwardCompletedAndDispose
            } else {
                return .disposeSubscription(subscriptions[atIndex])
            }
        }
    }

    private func perform(_ action: CalloutAction) {
        switch action {
        case .none:
            return
        case let .disposeSubscription(subscription):
            subscription.dispose()
        case let .evaluate(arguments):
            if isDisposed {
                return
            }

            do {
                let result = try parent.resultSelector(arguments)
                forwardOn(.next(result))
            } catch {
                forwardErrorAndDispose(error)
            }
        case .forwardCompletedAndDispose:
            forwardOn(.completed)
            dispose()
        case let .forwardErrorAndDispose(error):
            forwardOn(.error(error))
            dispose()
        }
    }

    private func forwardErrorAndDispose(_ error: Swift.Error) {
        let shouldTerminate = lock.performLocked { () -> Bool in
            if isStopped || isDisposed {
                return false
            }

            isStopped = true
            return true
        }

        if shouldTerminate {
            forwardOn(.error(error))
            dispose()
        }
    }

    override func dispose() {
        gate.dispose()
        super.dispose()
    }

    func run() -> Disposable {
        var j = 0
        for i in parent.sources {
            let index = j
            let source = i.asObservable()

            let disposable = source.subscribe(AnyObserver { event in
                self.on(event, atIndex: index)
            })
            subscriptions[j].setDisposable(disposable)
            j += 1
        }

        if parent.sources.isEmpty {
            forwardOn(.completed)
        }

        return Disposables.create(subscriptions)
    }
}

private final class ZipCollectionType<Collection: Swift.Collection, Result>: Producer<Result> where Collection.Element: ObservableConvertibleType {
    typealias ResultSelector = ([Collection.Element.Element]) throws -> Result

    let sources: Collection
    let resultSelector: ResultSelector
    let count: Int

    init(sources: Collection, resultSelector: @escaping ResultSelector) {
        self.sources = sources
        self.resultSelector = resultSelector
        count = self.sources.count
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Result {
        let sink = ZipCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
