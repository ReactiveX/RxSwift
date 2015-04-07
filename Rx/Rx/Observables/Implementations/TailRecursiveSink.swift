//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TailRecursiveSink<ElementType> : Sink<ElementType>, ObserverClassType {
    typealias Element = ElementType
    typealias StackElementType = (generator: GeneratorOf<Observable<Element>>, length: Int)
    
    var stack: [StackElementType] = []
    var disposed: Bool = false
    var subscription: SerialDisposable = SerialDisposable()
    
    // this is thread safe object
    var gate: AsyncLock = AsyncLock()
    
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(sources: [Observable<Element>]) -> Result<Disposable> {
        let generator: GeneratorOf<Observable<Element>> = GeneratorOf(sources.generate())
        self.stack.append((generator: generator, length: sources.count))
        
        let stateSnapshot = self.state
        
        return scheduleMoveNext() >>> {
            success(CompositeDisposable(
                self.subscription,
                stateSnapshot.cancel,
                AnonymousDisposable {
                    self.disposePrivate()
                }
            ))
        }
    }
    
    func scheduleMoveNext() -> Result<Void> {
        return schedule {
            self.moveNext()
        }
    }
    
    // simple implementation for now
    func schedule(action: () -> Result<Void>) -> Result<Void> {
        return self.gate.wait(action)
    }
    
    func moveNext() -> Result<Void> {
        var next: Observable<Element>? = nil;
        
        do {
            if self.stack.count == 0 {
                break
            }
            
            if disposed {
                return SuccessResult
            }
            
            var (e, l) = stack.last!
            
            let current = e.next()
        
            if current == nil {
                stack.removeLast()
                continue;
            }
        
            let r = l - 1
            
            stack.removeLast()
            stack.append((generator: e, length: r))
            
            next = current
            
            if r == 0 {
                stack.removeLast()
            }
            
            let nextSeq = extract(next!)
        
            if let nextSeq = nextSeq {
                let generator = GeneratorOf(nextSeq.generate())
                let length = nextSeq.count
             
                next = nil
            }
        } while next == nil
        
        if next == nil  {
            return done()
        }
        
        let d = SingleAssignmentDisposable()
        subscription.setDisposable(d)
        return next!.subscribeSafe(ObserverOf(self)) >== { subscription in
            d.setDisposable(subscription)
        }
    }
    
    private func disposePrivate() {
        disposed = true
        
        stack.removeAll(keepCapacity: false)
    }
    
    func done() -> Result<Void> {
        let result = state.observer.on(.Completed)
        self.dispose()
        return result
    }
    
    func extract(observable: Observable<Element>) -> [Observable<Element>]? {
        return abstractMethod()
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        return abstractMethod()
    }
}