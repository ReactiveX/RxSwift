//
//  Zip+Collection.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

extension Observable {
    /**
     Merges the specified observable sequences into one observable sequence by using the selector function whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - parameter resultSelector: Function to invoke for each series of elements at corresponding indexes in the sources.
     - returns: An observable sequence containing the result of combining elements of the sources using the specified result selector function.
     */
    public static func zip<C: Collection>(_ collection: C, _ resultSelector: @escaping ([C.Iterator.Element.E]) throws -> Element) -> Observable<Element>
        where C.Iterator.Element: ObservableType {
        return ZipCollectionType(sources: collection, resultSelector: resultSelector)
    }

    /**
     Merges the specified observable sequences into one observable sequence whenever all of the observable sequences have produced an element at a corresponding index.

     - seealso: [zip operator on reactivex.io](http://reactivex.io/documentation/operators/zip.html)

     - returns: An observable sequence containing the result of combining elements of the sources.
     */
    public static func zip<C: Collection>(_ collection: C) -> Observable<[Element]>
        where C.Iterator.Element: ObservableType, C.Iterator.Element.E == Element {
        return ZipCollectionType(sources: collection, resultSelector: { $0 })
    }
    
}

final fileprivate class ZipCollectionTypeSink<C: Collection, O: ObserverType>
    : Sink<O> where C.Iterator.Element : ObservableConvertibleType {
    typealias R = O.E
    typealias Parent = ZipCollectionType<C, R>
    typealias SourceElement = C.Iterator.Element.E
    
    private let _parent: Parent
    
    private let _lock = RecursiveLock()
    
    // state
    private var _numberOfValues = 0
    private var _values: [Queue<SourceElement>]
    private var _isDone: [Bool]
    private var _numberOfDone = 0
    private var _subscriptions: [SingleAssignmentDisposable]
    
    init(parent: Parent, observer: O, cancel: Cancelable) {
        _parent = parent
        _values = [Queue<SourceElement>](repeating: Queue(capacity: 4), count: parent.count)
        _isDone = [Bool](repeating: false, count: parent.count)
        _subscriptions = Array<SingleAssignmentDisposable>()
        _subscriptions.reserveCapacity(parent.count)
        
        for _ in 0 ..< parent.count {
            _subscriptions.append(SingleAssignmentDisposable())
        }
        
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(_ event: Event<SourceElement>, atIndex: Int) {
        _lock.lock(); defer { _lock.unlock() } // {
            switch event {
            case .next(let element):
                _values[atIndex].enqueue(element)
                
                if _values[atIndex].count == 1 {
                    _numberOfValues += 1
                }
                
                if _numberOfValues < _parent.count {
                    if _numberOfDone == _parent.count - 1 {
                        self.forwardOn(.completed)
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
                        arguments.append(_values[i].dequeue()!)
                        if _values[i].count > 0 {
                            _numberOfValues += 1
                        }
                    }
                    
                    let result = try _parent.resultSelector(arguments)
                    self.forwardOn(.next(result))
                }
                catch let error {
                    self.forwardOn(.error(error))
                    self.dispose()
                }
                
            case .error(let error):
                self.forwardOn(.error(error))
                self.dispose()
            case .completed:
                if _isDone[atIndex] {
                    return
                }
                
                _isDone[atIndex] = true
                _numberOfDone += 1
                
                if _numberOfDone == _parent.count {
                    self.forwardOn(.completed)
                    self.dispose()
                }
                else {
                    _subscriptions[atIndex].dispose()
                }
            }
        // }
    }
    
    func run() -> Disposable {
        var j = 0
        for i in _parent.sources {
            let index = j
            let source = i.asObservable()

            let disposable = source.subscribe(AnyObserver { event in
                self.on(event, atIndex: index)
                })
            _subscriptions[j].setDisposable(disposable)
            j += 1
        }

        if _parent.sources.isEmpty {
            self.forwardOn(.completed)
        }
        
        return Disposables.create(_subscriptions)
    }
}

final fileprivate class ZipCollectionType<C: Collection, R> : Producer<R> where C.Iterator.Element : ObservableConvertibleType {
    typealias ResultSelector = ([C.Iterator.Element.E]) throws -> R
    
    let sources: C
    let resultSelector: ResultSelector
    let count: Int
    
    init(sources: C, resultSelector: @escaping ResultSelector) {
        self.sources = sources
        self.resultSelector = resultSelector
        self.count = Int(Int64(self.sources.count))
    }
    
    override func run<O : ObserverType>(_ observer: O, cancel: Cancelable) -> (sink: Disposable, subscription: Disposable) where O.E == R {
        let sink = ZipCollectionTypeSink(parent: self, observer: observer, cancel: cancel)
        let subscription = sink.run()
        return (sink: sink, subscription: subscription)
    }
}
