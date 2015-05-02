//
//  TailRecursiveSink.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class TailRecursiveSink<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = ElementType
    typealias StackElementType = (generator: GeneratorOf<Observable<Element>>, length: Int)
    
    var stack: [StackElementType] = []
    var disposed: Bool = false
    var subscription = SerialDisposable()
    
    // this is thread safe object
    var gate: AsyncLock = AsyncLock()
    
    override init(observer: ObserverOf<Element>, cancel: Disposable) {
        super.init(observer: observer, cancel: cancel)
    }
    
    func run(sources: [Observable<Element>]) -> Disposable {
        let generator: GeneratorOf<Observable<Element>> = GeneratorOf(sources.generate())
        self.stack.append((generator: generator, length: sources.count))
        
        let stateSnapshot = self.state
        
        scheduleMoveNext()
        return CompositeDisposable(
                self.subscription,
                stateSnapshot.cancel,
                AnonymousDisposable {
                    self.disposePrivate()
                }
            )
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
    
    func moveNext() {
        var next: Observable<Element>? = nil;
        
        do {
            if self.stack.count == 0 {
                break
            }
            
            if disposed {
                return
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
            done()
            return
        }
        
        let subscription2 = next!.subscribe(self)
        subscription.setDisposable(subscription2)
    }
    
    private func disposePrivate() {
        disposed = true
        
        stack.removeAll(keepCapacity: false)
    }
    
    func done() {
        observer.on(.Completed)
        self.dispose()
    }
    
    func extract(observable: Observable<Element>) -> [Observable<Element>]? {
        return abstractMethod()
    }
    
    func on(event: Event<Element>) {
        return abstractMethod()
    }
}