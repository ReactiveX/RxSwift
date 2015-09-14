//
//  Zip+CollectionType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ZipCollectionTypeSink<C: CollectionType, R, O: ObserverType where C.Generator.Element : ObservableType, O.E == R> : Sink<O> {
    typealias Parent = ZipCollectionType<C, R>
    typealias SourceElement = C.Generator.Element.E
    
    let parent: Parent
    
    let lock = NSRecursiveLock()
    
    // state
    var numberOfValues = 0
    var values: [Queue<SourceElement>]
    var isDone: [Bool]
    var numberOfDone = 0
    var subscriptions: [SingleAssignmentDisposable]
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        self.parent = parent
        self.values = [Queue<SourceElement>](count: parent.count, repeatedValue: Queue(capacity: 4))
        self.isDone = [Bool](count: parent.count, repeatedValue: false)
        self.subscriptions = Array<SingleAssignmentDisposable>()
        self.subscriptions.reserveCapacity(parent.count)
        
        for _ in 0 ..< parent.count {
            self.subscriptions.append(SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceElement>, atIndex: Int) {
        lock.performLocked {
            switch event {
            case .Next(let element):
                values[atIndex].enqueue(element)
                
                if values[atIndex].count == 1 {
                    numberOfValues++
                }
                
                if numberOfValues < parent.count {
                    let numberOfOthersThatAreDone = self.numberOfDone - (isDone[atIndex] ? 1 : 0)
                    if numberOfOthersThatAreDone == self.parent.count - 1 {
                        self.observer?.on(.Completed)
                        self.dispose()
                    }
                    return
                }
                
                do {
                    var arguments = [SourceElement]()
                    arguments.reserveCapacity(parent.count)
                    
                    // recalculate number of values
                    numberOfValues = 0
                    
                    for i in 0 ..< values.count {
                        arguments.append(values[i].dequeue())
                        if values[i].count > 0 {
                            numberOfValues++
                        }
                    }
                    
                    let result = try parent.resultSelector(arguments)
                    self.observer?.on(.Next(result))
                }
                catch let error {
                    self.observer?.on(.Error(error))
                    self.dispose()
                }
                
            case .Error(let error):
                self.observer?.on(.Error(error))
                self.dispose()
            case .Completed:
                if isDone[atIndex] {
                    return
                }
                
                isDone[atIndex] = true
                numberOfDone++
                
                if numberOfDone == self.parent.count {
                    self.observer?.on(.Completed)
                    self.dispose()
                }
                else {
                    self.subscriptions[atIndex].dispose()
                }
            }
        }
    }
    
    func run() -> Disposable {
        var j = 0
        for i in parent.sources.startIndex ..< parent.sources.endIndex {
            let index = j
            self.subscriptions[j].disposable = self.parent.sources[i].subscribeSafe(ObserverOf { event in
                self.on(event, atIndex: index)
                })
            j++
        }
        
        return CompositeDisposable(disposables: self.subscriptions.map { $0 })
    }
}

class ZipCollectionType<C: CollectionType, R where C.Generator.Element : ObservableType> : Producer<R> {
    typealias ResultSelector = [C.Generator.Element.E] throws -> R
    
    let sources: C
    let resultSelector: ResultSelector
    let count: Int
    
    init(sources: C, resultSelector: ResultSelector) {
        self.sources = sources
        self.resultSelector = resultSelector
        self.count = Int(self.sources.count.toIntMax())
    }
    
    override func run<O : ObserverType where O.E == R>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = ZipCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return sink.run()
    }
}