//
//  GroupBy.swift
//  RxSwift
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public extension ObservableType {
    /*
     Groups the elements of an observable sequence according to a specified key selector function.

     - seealso: [groupBy operator on reactivex.io](http://reactivex.io/documentation/operators/groupby.html)

     - parameter keySelector: A function to extract the key for each element.
     - returns: A sequence of observable groups, each of which corresponds to a unique key value, containing all elements that share that same key value.
     */
    func groupBy<Key: Hashable>(keySelector: @escaping (Element) throws -> Key)
        -> Observable<GroupedObservable<Key, Element>>
    {
        GroupBy(source: asObservable(), selector: keySelector)
    }
}

private final class GroupedObservableImpl<Element>: Observable<Element> {
    private var subject: PublishSubject<Element>
    private var refCount: RefCountDisposable

    init(subject: PublishSubject<Element>, refCount: RefCountDisposable) {
        self.subject = subject
        self.refCount = refCount
    }

    override func subscribe<Observer: ObserverType>(_ observer: Observer) -> Disposable where Observer.Element == Element {
        let release = refCount.retain()
        let subscription = subject.subscribe(observer)
        return Disposables.create(release, subscription)
    }
}

private final class GroupBySink<Key: Hashable, Element, Observer: ObserverType>:
    Sink<Observer>,
    ObserverType where Observer.Element == GroupedObservable<Key, Element>
{
    typealias ResultType = Observer.Element
    typealias Parent = GroupBy<Key, Element>

    private let parent: Parent
    private let subscription = SingleAssignmentDisposable()
    private var refCountDisposable: RefCountDisposable!
    private var groupedSubjectTable: [Key: PublishSubject<Element>]

    init(parent: Parent, observer: Observer, cancel: Cancelable) {
        self.parent = parent
        groupedSubjectTable = [Key: PublishSubject<Element>]()
        super.init(observer: observer, cancel: cancel)
    }

    func run() -> Disposable {
        refCountDisposable = RefCountDisposable(disposable: subscription)

        subscription.setDisposable(parent.source.subscribe(self))

        return refCountDisposable
    }

    private func onGroupEvent(key: Key, value: Element) {
        if let writer = groupedSubjectTable[key] {
            writer.on(.next(value))
        } else {
            let writer = PublishSubject<Element>()
            groupedSubjectTable[key] = writer

            let group = GroupedObservable(
                key: key,
                source: GroupedObservableImpl(subject: writer, refCount: refCountDisposable)
            )

            forwardOn(.next(group))
            writer.on(.next(value))
        }
    }

    final func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            do {
                let groupKey = try parent.selector(value)
                onGroupEvent(key: groupKey, value: value)
            } catch let e {
                self.error(e)
                return
            }
        case let .error(e):
            error(e)
        case .completed:
            forwardOnGroups(event: .completed)
            forwardOn(.completed)
            subscription.dispose()
            dispose()
        }
    }

    final func error(_ error: Swift.Error) {
        forwardOnGroups(event: .error(error))
        forwardOn(.error(error))
        subscription.dispose()
        dispose()
    }

    final func forwardOnGroups(event: Event<Element>) {
        for writer in groupedSubjectTable.values {
            writer.on(event)
        }
    }
}

private final class GroupBy<Key: Hashable, Element>: Producer<GroupedObservable<Key, Element>> {
    typealias KeySelector = (Element) throws -> Key

    fileprivate let source: Observable<Element>
    fileprivate let selector: KeySelector

    init(source: Observable<Element>, selector: @escaping KeySelector) {
        self.source = source
        self.selector = selector
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == GroupedObservable<Key, Element> {
        let sink = GroupBySink(parent: self, observer: observer, cancel: cancel)
        return (sink: sink, subscription: sink.run())
    }
}
