//
//  CombineLatest.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol CombineLatestProtocol: AnyObject {
    func next(_ index: Int)
    func fail(_ error: Swift.Error)
    func done(_ index: Int)
}

class CombineLatestSink<Observer: ObserverType>:
    Sink<Observer>,
    CombineLatestProtocol
{
    typealias Element = Observer.Element

    let lock = RecursiveLock()

    private let arity: Int
    private var numberOfValues = 0
    private var numberOfDone = 0
    private var hasValue: [Bool]
    private var isDone: [Bool]

    init(arity: Int, observer: Observer, cancel: Cancelable) {
        self.arity = arity
        hasValue = [Bool](repeating: false, count: arity)
        isDone = [Bool](repeating: false, count: arity)

        super.init(observer: observer, cancel: cancel)
    }

    func getResult() throws -> Element {
        rxAbstractMethod()
    }

    func next(_ index: Int) {
        if !hasValue[index] {
            hasValue[index] = true
            numberOfValues += 1
        }

        if numberOfValues == arity {
            do {
                let result = try getResult()
                forwardOn(.next(result))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        } else {
            var allOthersDone = true

            for i in 0 ..< arity {
                if i != index, !isDone[i] {
                    allOthersDone = false
                    break
                }
            }

            if allOthersDone {
                forwardOn(.completed)
                dispose()
            }
        }
    }

    func fail(_ error: Swift.Error) {
        forwardOn(.error(error))
        dispose()
    }

    func done(_ index: Int) {
        if isDone[index] {
            return
        }

        isDone[index] = true
        numberOfDone += 1

        if numberOfDone == arity {
            forwardOn(.completed)
            dispose()
        }
    }
}

final class CombineLatestObserver<Element>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias ValueSetter = (Element) -> Void

    private let parent: CombineLatestProtocol

    let lock: RecursiveLock
    private let index: Int
    private let this: Disposable
    private let setLatestValue: ValueSetter

    init(lock: RecursiveLock, parent: CombineLatestProtocol, index: Int, setLatestValue: @escaping ValueSetter, this: Disposable) {
        self.lock = lock
        self.parent = parent
        self.index = index
        self.this = this
        self.setLatestValue = setLatestValue
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        switch event {
        case let .next(value):
            setLatestValue(value)
            parent.next(index)
        case let .error(error):
            this.dispose()
            parent.fail(error)
        case .completed:
            this.dispose()
            parent.done(index)
        }
    }
}
