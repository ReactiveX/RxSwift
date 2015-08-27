//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// This class is usually used with `GeneratorOf` version of the operators.
class TailRecursiveSink<S: SequenceType, O: ObserverType where S.Generator.Element: ObservableType, S.Generator.Element.E == O.E> : Sink<O>, ObserverType {
    typealias E = O.E
    
    var generators: [S.Generator] = []
    var disposed: Bool = false
    var subscription = SerialDisposable()
    
    // this is thread safe object
    var gate: AsyncLock = AsyncLock()
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(sources: S.Generator) -> Disposable {
        self.generators.append(sources)
        
        scheduleMoveNext()
        
        let disposeSinkStack = AnonymousDisposable {
            self.schedule {
                self.disposePrivate()
            }
        }
        
        return StableCompositeDisposable.create(self.subscription, disposeSinkStack)
    }
    
    func scheduleMoveNext() {
        return schedule {
            self.moveNext()
        }
    }
    
    // simple implementation for now
    func schedule(action: () -> Void) {
        self.gate.wait(action)
    }

    func done() {
        observer?.on(.Completed)
        self.dispose()
    }
    
    func extract(observable: Observable<E>) -> S.Generator? {
        return abstractMethod()
    }
    
    func on(event: Event<E>) {
        return abstractMethod()
    }
    
    // should be done on gate locked

    private func moveNext() {
        var next: Observable<E>? = nil;
        
        repeat {
            if self.generators.count == 0 {
                break
            }
            
            if disposed {
                return
            }
            
            var e = generators.last!
            
            let nextCandidate = e.next()?.asObservable()
            generators.removeLast()
            generators.append(e)
        
            if nextCandidate == nil {
                generators.removeLast()
                continue;
            }
       
            let nextGenerator = extract(nextCandidate!)
        
            if let nextGenerator = nextGenerator {
                self.generators.append(nextGenerator)
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
        subscription.disposable = subscription2
    }
    
    private func disposePrivate() {
        disposed = true
        generators.removeAll(keepCapacity: false)
    }
    
}