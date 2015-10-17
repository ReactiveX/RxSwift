//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/// This class is usually used with `Generator` version of the operators.
class TailRecursiveSink<S: SequenceType, O: ObserverType where S.Generator.Element: ObservableConvertibleType, S.Generator.Element.E == O.E> : Sink<O>, ObserverType {
    typealias E = O.E
    
    private var _generators: [S.Generator] = []
    private var _disposed: Bool = false
    private var _subscription = SerialDisposable()
    
    // this is thread safe objec
    private var _gate: AsyncLock = AsyncLock()
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(sources: S.Generator) -> Disposable {
        _generators.append(sources)
        
        scheduleMoveNext()
        
        let disposeSinkStack = AnonymousDisposable {
            self.schedule {
                self.disposePrivate()
            }
        }
        
        return StableCompositeDisposable.create(_subscription, disposeSinkStack)
    }
    
    func scheduleMoveNext() {
        return schedule {
            self.moveNext()
        }
    }
    
    // simple implementation for now
    func schedule(action: () -> Void) {
        _gate.wait(action)
    }

    func done() {
        observer?.on(.Completed)
        dispose()
    }
    
    func extract(observable: Observable<E>) -> S.Generator? {
        abstractMethod()
    }
    
    func on(event: Event<E>) {
        abstractMethod()
    }
    
    // should be done on gate locked

    private func moveNext() {
        var next: Observable<E>? = nil;
        
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
        
        let subscription2 = next!.subscribeSafe(self)
        _subscription.disposable = subscription2
    }
    
    private func disposePrivate() {
        _disposed = true
        _generators.removeAll(keepCapacity: false)
    }
    
}