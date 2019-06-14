//
//  AllSatisfy.swift
//  RxSwift
//
//  Created by Anton Nazarov on 14/06/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//


extension ObservableType {

    /**
    Converts an Observable into a Single that indicates whether all received elements pass a given predicate. If the predicate returns `false`, the Single emits a `false` value and completes. If the upstream Observable finishes normally, this Single emits a `true` value and completes.

     - seealso: [allSatify operator on Swift.Sequence](https://developer.apple.com/documentation/swift/sequence/2996794-allsatisfy)

     - parameter predicate: A closure that evaluates each received element. Return `true` to continue, or `false` to complete.
     - returns: A Single that emits a Boolean value that indicates whether all received elements pass a given predicate
     */
    public func allSatisfy(_ predicate: @escaping (Element) throws -> Bool)
        -> Single<Bool> {
            return PrimitiveSequence(raw: AllSatisfy(source: self.asObservable(), predicate: predicate))
    }
}


final private class AllSatisfySink<SourceType, Observer: ObserverType>: Sink<Observer>, ObserverType where Observer.Element == Bool {
    typealias Predicate = (SourceType) throws -> Bool
    typealias Element = SourceType

    private let _predicate: Predicate

    init(predicate: @escaping Predicate, observer: Observer, cancel: Cancelable) {
        self._predicate = predicate
        super.init(observer: observer, cancel: cancel)
    }

    func on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            do {
                let satisfies = try self._predicate(value)
                guard !satisfies else { return }
                self.forwardOn(.next(false))
                self.forwardOn(.completed)
                self.dispose()
            }
            catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        case .completed:
            self.forwardOn(.next(true))
            self.forwardOn(.completed)
            self.dispose()
        case let .error(error):
            self.forwardOn(.error(error))
            self.dispose()
        }
    }
}

final private class AllSatisfy<Element>: Producer<Bool> {
    typealias Predicate = (Element) throws -> Bool

    private let _source: Observable<Element>
    private let _predicate: Predicate

    init(source: Observable<Element>, predicate: @escaping Predicate) {
        self._source = source
        self._predicate = predicate
    }

    override func run<Observer: ObserverType>(_ observer: Observer, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where Observer.Element == Bool {
        let sink = AllSatisfySink(predicate: self._predicate, observer: observer, cancel: cancel)
        let subscription = self._source.subscribe(sink)
        return (sink: sink, subscription: subscription)
    }
}
