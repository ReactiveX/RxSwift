//
//  CombineLatest+Collection.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - parameter resultSelector: Function to invoke whenever any of the sources produces an element.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    static func combineLatest<Collection: Swift.Collection>(_ collection: Collection, resultSelector: @escaping ([Collection.Element.Element]) throws -> Element) -> Observable<Element>
        where Collection.Element: ObservableType
    {
        CombineLatestCollectionType(sources: collection, resultSelector: resultSelector)
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever any of the observable sequences produces an element.

     - seealso: [combinelatest operator on reactivex.io](http://reactivex.io/documentation/operators/combinelatest.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    static func combineLatest<Collection: Swift.Collection>(_ collection: Collection) -> Observable<[Element]>
        where Collection.Element: ObservableType, Collection.Element.Element == Element
    {
        CombineLatestCollectionType(sources: collection, resultSelector: { $0 })
    }
}

final class CombineLatestCollectionTypeSink<Collection: Swift.Collection, Observer: ObserverType>:
    Sink<Observer> where Collection.Element: ObservableConvertibleType
{
    typealias Result = Observer.Element
    typealias Parent = CombineLatestCollectionType<Collection, Result>
    typealias SourceElement = Collection.Element.Element

    let parent: Parent

    let lock = RecursiveLock()

    // state
    var numberOfValues = 0
    var values: [SourceElement?]
    var isDone: [Bool]
    var numberOfDone = 0
    var subscriptions: [SingleAssignmentDisposable]

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        values = [SourceElement?](repeating: nil, count: parent.count)
        isDone = [Bool](repeating: false, count: parent.count)
        subscriptions = [SingleAssignmentDisposable]()
        subscriptions.reserveCapacity(parent.count)

        for _ in 0 ..< parent.count {
            subscriptions.append(SingleAssignmentDisposable())
        }

        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<SourceElement>, atIndex: Int) {
        lock.lock(); defer { self.lock.unlock() }
        switch event {
        case let .next(element):
            if values[atIndex] == nil {
                numberOfValues += 1
            }

            values[atIndex] = element

            if numberOfValues < parent.count {
                let numberOfOthersThatAreDone = numberOfDone - (isDone[atIndex] ? 1 : 0)
                if numberOfOthersThatAreDone == parent.count - 1 {
                    forwardOn(.completed)
                    dispose()
                }
                return
            }

            do {
                let result = try parent.resultSelector(values.map { $0! })
                forwardOn(.next(result))
            } catch {
                forwardOn(.error(error))
                dispose()
            }

        case let .error(error):
            forwardOn(.error(error))
            dispose()

        case .completed:
            if isDone[atIndex] {
                return
            }

            isDone[atIndex] = true
            numberOfDone += 1

            if numberOfDone == parent.count {
                forwardOn(.completed)
                dispose()
            } else {
                subscriptions[atIndex].dispose()
            }
        }
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
            do {
                let result = try parent.resultSelector([])
                forwardOn(.next(result))
                forwardOn(.completed)
                dispose()
            } catch {
                forwardOn(.error(error))
                dispose()
            }
        }

        return Disposables.create(subscriptions)
    }
}

final class CombineLatestCollectionType<Collection: Swift.Collection, Result>: Producer<Result> where Collection.Element: ObservableConvertibleType {
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
        let sink = CombineLatestCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
