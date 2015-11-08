//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum TailRecursiveSinkCommand {
    case MoveNext
    case Dispose
}

/// This class is usually used with `Generator` version of the operators.
class TailRecursiveSink<S: SequenceType, O: ObserverType where S.Generator.Element: ObservableConvertibleType, S.Generator.Element.E == O.E>
    : Sink<O>
    , InvocableWithValueType {
    typealias Value = TailRecursiveSinkCommand
    typealias E = O.E
    
    var _generators:[S.Generator] = []
    var _disposed = false
    var _subscription = SerialDisposable()
    
    // this is thread safe object
    var _gate = AsyncLock<InvocableScheduledItem<TailRecursiveSink<S, O>>>()
    
    override init(observer: O) {
        super.init(observer: observer)
    }
    
    func run(sources: S.Generator) -> Disposable {
        _generators.append(sources)

        schedule(.MoveNext)
        
        return _subscription
    }

    func invoke(command: TailRecursiveSinkCommand) {
        switch command {
            case .Dispose:
                disposeCommand()
            case .MoveNext:
                moveNextCommand()
        }
    }
    
    // simple implementation for now
    func schedule(command: TailRecursiveSinkCommand) {
        _gate.invoke(InvocableScheduledItem(invocable: self, state: command))
    }

    func done() {
        forwardOn(.Completed)
        dispose()
    }
    
    func extract(observable: Observable<E>) -> S.Generator? {
        abstractMethod()
    }
    
    // should be done on gate locked

    private func moveNextCommand() {
        var next: Observable<E>? = nil
        
        repeat {
            if _generators.count == 0 {
                break
            }
            
            if _disposed {
                return
            }
            
            var e = _generators.last!
            
            let nextCandidate = e.next()?.asObservable()
            _generators.removeLast()
            _generators.append(e)

            if nextCandidate == nil {
                _generators.removeLast()
                continue;
            }
       
            let nextGenerator = extract(nextCandidate!)
        
            if let nextGenerator = nextGenerator {
                self._generators.append(nextGenerator)
            }
            else {
                next = nextCandidate
            }
        } while next == nil
        
        if next == nil  {
            done()
            return
        }
        
        let subscription2 = subscribeToNext(next!)
        _subscription.disposable = subscription2
    }

    func subscribeToNext(source: Observable<E>) -> Disposable {
        abstractMethod()
    }

    func disposeCommand() {
        _disposed = true
        _generators.removeAll(keepCapacity: false)
    }

    override func dispose() {
        super.dispose()

        _subscription.dispose()

        schedule(.Dispose)
    }
}
