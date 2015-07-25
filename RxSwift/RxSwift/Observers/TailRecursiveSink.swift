//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// This class is usually used with `GeneratorOf` version of the operators.
class TailRecursiveSink<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    
    var generators: [GeneratorOf<Observable<Element>>] = []
    var disposed: Bool = false
    var subscription = SerialDisposable()
    
    // this is thread safe object
    var gate: AsyncLock = AsyncLock()
    
    override init(observer: O, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(sources: GeneratorOf<Observable<Element>>) -> Disposable {
        self.generators.append(sources.generate())
        
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
        trySendCompleted(observer)
        self.dispose()
    }
    
    func extract(observable: Observable<Element>) -> GeneratorOf<Observable<Element>>? {
        return abstractMethod()
    }
    
    func on(event: Event<Element>) {
        return abstractMethod()
    }
    
    // should be done on gate locked

    private func moveNext() {
        var next: Observable<Element>? = nil;
        
        do {
            if self.generators.count == 0 {
                break
            }
            
            if disposed {
                return
            }
            
            var e = generators.last!
            
            let nextCandidate = e.next()
        
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