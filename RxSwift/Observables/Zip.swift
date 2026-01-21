//
//  Zip.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

protocol ZipSinkProtocol: AnyObject {
    func next(_ index: Int)
    func fail(_ error: Swift.Error)
    func done(_ index: Int)
}

class ZipSink<Observer: ObserverType>: Sink<Observer>, ZipSinkProtocol {
    typealias Element = Observer.Element

    let arity: Int

    let lock = RecursiveLock()

    // state
    private var isDone: [Bool]

    init(arity: Int, observer: Observer, cancel: Cancelable) {
        isDone = [Bool](repeating: false, count: arity)
        self.arity = arity

        super.init(observer: observer, cancel: cancel)
    }

    func getResult() throws -> Element {
        rxAbstractMethod()
    }

    func hasElements(_: Int) -> Bool {
        rxAbstractMethod()
    }

    func next(_: Int) {
        var hasValueAll = true

        for i in 0 ..< arity {
            if !hasElements(i) {
                hasValueAll = false
                break
            }
        }

        if hasValueAll {
            do {
                let result = try getResult()
                forwardOn(.next(result))
            } catch let e {
                self.forwardOn(.error(e))
                self.dispose()
            }
        }
    }

    func fail(_ error: Swift.Error) {
        forwardOn(.error(error))
        dispose()
    }

    func done(_ index: Int) {
        isDone[index] = true

        var allDone = true

        for done in isDone where !done {
            allDone = false
            break
        }

        if allDone {
            forwardOn(.completed)
            dispose()
        }
    }
}

final class ZipObserver<Element>:
    ObserverType,
    LockOwnerType,
    SynchronizedOnType
{
    typealias ValueSetter = (Element) -> Void

    private var parent: ZipSinkProtocol?

    let lock: RecursiveLock

    // state
    private let index: Int
    private let this: Disposable
    private let setNextValue: ValueSetter

    init(lock: RecursiveLock, parent: ZipSinkProtocol, index: Int, setNextValue: @escaping ValueSetter, this: Disposable) {
        self.lock = lock
        self.parent = parent
        self.index = index
        self.this = this
        self.setNextValue = setNextValue
    }

    func on(_ event: Event<Element>) {
        synchronizedOn(event)
    }

    func synchronized_on(_ event: Event<Element>) {
        if parent != nil {
            switch event {
            case .next:
                break
            case .error:
                this.dispose()
            case .completed:
                this.dispose()
            }
        }

        if let parent {
            switch event {
            case let .next(value):
                setNextValue(value)
                parent.next(index)
            case let .error(error):
                parent.fail(error)
            case .completed:
                parent.done(index)
            }
        }
    }
}
