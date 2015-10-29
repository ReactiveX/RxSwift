//
//  Zip+CollectionType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ZipCollectionTypeSink<C: CollectionType, R, O: ObserverType where C.Generator.Element : ObservableConvertibleType, O.E == R> : Sink<O> {
    typealias Parent = ZipCollectionType<C, R>
    typealias SourceElement = C.Generator.Element.E
    
    private let _parent: Parent
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _numberOfValues = 0
    private var _values: [Queue<SourceElement>]
    private var _isDone: [Bool]
    private var _numberOfDone = 0
    private var _subscriptions: [SingleAssignmentDisposable]
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        _values = [Queue<SourceElement>](count: parent.count, repeatedValue: Queue(capacity: 4))
        _isDone = [Bool](count: parent.count, repeatedValue: false)
        _subscriptions = Array<SingleAssignmentDisposable>()
        _subscriptions.reserveCapacity(parent.count)
        
        for _ in 0 ..< parent.count {
            _subscriptions.append(SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<SourceElement>, atIndex: Int) {
        _lock.performLocked {
            switch event {
            case .Next(let element):
                _values[atIndex].enqueue(element)
                
                if _values[atIndex].count == 1 {
                    _numberOfValues++
                }
                
                if _numberOfValues < _parent.count {
                    let numberOfOthersThatAreDone = _numberOfDone - (_isDone[atIndex] ? 1 : 0)
                    if numberOfOthersThatAreDone == _parent.count - 1 {
                        self.observer?.on(.Completed)
                        self.dispose()
                    }
                    return
                }
                
                do {
                    var arguments = [SourceElement]()
                    arguments.reserveCapacity(_parent.count)
                    
                    // recalculate number of values
                    _numberOfValues = 0
                    
                    for i in 0 ..< _values.count {
                        arguments.append(_values[i].dequeue())
                        if _values[i].count > 0 {
                            _numberOfValues++
                        }
                    }
                    
                    let result = try _parent.resultSelector(arguments)
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
                if _isDone[atIndex] {
                    return
                }
                
                _isDone[atIndex] = true
                _numberOfDone++
                
                if _numberOfDone == _parent.count {
                    self.observer?.on(.Completed)
                    self.dispose()
                }
                else {
                    _subscriptions[atIndex].dispose()
                }
            }
        }
    }
    
    func run() -> Disposable {
        var j = 0
        for i in _parent.sources.startIndex ..< _parent.sources.endIndex {
            let index = j
            let source = _parent.sources[i].asObservable()
            _subscriptions[j].disposable = source.subscribe(AnyObserver { event in
                self.on(event, atIndex: index)
                })
            j++
        }
        
        return CompositeDisposable(disposables: _subscriptions.map { $0 })
    }
}

class ZipCollectionType<C: CollectionType, R where C.Generator.Element : ObservableConvertibleType> : Producer<R> {
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
