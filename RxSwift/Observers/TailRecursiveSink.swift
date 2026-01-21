//
//  TailRecursiveSink.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

enum TailRecursiveSinkCommand {
    case moveNext
    case dispose
}

#if DEBUG || TRACE_RESOURCES
public var maxTailRecursiveSinkStackSize = 0
#endif

/// This class is usually used with `Generator` version of the operators.
class TailRecursiveSink<Sequence: Swift.Sequence, Observer: ObserverType>:
    Sink<Observer>,
    InvocableWithValueType where Sequence.Element: ObservableConvertibleType, Sequence.Element.Element == Observer.Element
{
    typealias Value = TailRecursiveSinkCommand
    typealias Element = Observer.Element
    typealias SequenceGenerator = (generator: Sequence.Iterator, remaining: IntMax?)

    var generators: [SequenceGenerator] = []
    var disposed = false
    var subscription = SerialDisposable()

    // this is thread safe object
    var gate = AsyncLock<InvocableScheduledItem<TailRecursiveSink<Sequence, Observer>>>()

    override init(observer: Observer, cancel: Cancelable) {
        super.init(observer: observer, cancel: cancel)
    }

    func run(_ sources: SequenceGenerator) -> Disposable {
        generators.append(sources)

        schedule(.moveNext)

        return subscription
    }

    func invoke(_ command: TailRecursiveSinkCommand) {
        switch command {
        case .dispose:
            disposeCommand()
        case .moveNext:
            moveNextCommand()
        }
    }

    // simple implementation for now
    func schedule(_ command: TailRecursiveSinkCommand) {
        gate.invoke(InvocableScheduledItem(invocable: self, state: command))
    }

    func done() {
        forwardOn(.completed)
        dispose()
    }

    func extract(_: Observable<Element>) -> SequenceGenerator? {
        rxAbstractMethod()
    }

    // should be done on gate locked

    private func moveNextCommand() {
        var next: Observable<Element>?

        repeat {
            guard let (g, left) = generators.last else {
                break
            }

            if isDisposed {
                return
            }

            generators.removeLast()

            var e = g

            guard let nextCandidate = e.next()?.asObservable() else {
                continue
            }

            // `left` is a hint of how many elements are left in generator.
            // In case this is the last element, then there is no need to push
            // that generator on stack.
            //
            // This is an optimization used to make sure in tail recursive case
            // there is no memory leak in case this operator is used to generate non terminating
            // sequence.

            if let knownOriginalLeft = left {
                // `- 1` because generator.next() has just been called
                if knownOriginalLeft - 1 >= 1 {
                    generators.append((e, knownOriginalLeft - 1))
                }
            } else {
                generators.append((e, nil))
            }

            let nextGenerator = extract(nextCandidate)

            if let nextGenerator {
                generators.append(nextGenerator)
                #if DEBUG || TRACE_RESOURCES
                if maxTailRecursiveSinkStackSize < generators.count {
                    maxTailRecursiveSinkStackSize = generators.count
                }
                #endif
            } else {
                next = nextCandidate
            }
        } while next == nil

        guard let existingNext = next else {
            done()
            return
        }

        let disposable = SingleAssignmentDisposable()
        subscription.disposable = disposable
        disposable.setDisposable(subscribeToNext(existingNext))
    }

    func subscribeToNext(_: Observable<Element>) -> Disposable {
        rxAbstractMethod()
    }

    func disposeCommand() {
        disposed = true
        generators.removeAll(keepingCapacity: false)
    }

    override func dispose() {
        super.dispose()

        subscription.dispose()
        gate.dispose()

        schedule(.dispose)
    }
}
