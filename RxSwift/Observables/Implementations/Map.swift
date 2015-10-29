//
//  Map.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class MapSink<SourceType, O : ObserverType> : Sink<O>, ObserverType {
    typealias ResultType = O.E
    typealias Element = SourceType
    typealias Parent = Map<SourceType, ResultType>
    
    private let _parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
        _parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func performMap(element: SourceType) throws -> ResultType {
        abstractMethod()
    }

    func on(event: Event<SourceType>) {
        let observer = super.observer
        
        switch event {
        case .Next(let element):
            do {
                let mappedElement = try performMap(element)
                observer?.on(.Next(mappedElement))
            }
            catch let e {
                observer?.on(.Error(e))
                dispose()
            }
        case .Error(let error):
            observer?.on(.Error(error))
            dispose()
        case .Completed:
            observer?.on(.Completed)
            dispose()
        }
    }
}

class MapSink1<SourceType, O: ObserverType> : MapSink<SourceType, O> {
    typealias ResultType = O.E
    
    override init(parent: Map<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    
    override func performMap(element: SourceType) throws -> ResultType {
        return try _parent._selector1!(element)
    }
}

class MapSink2<SourceType, O: ObserverType> : MapSink<SourceType, O> {
    typealias ResultType = O.E
    
    private var _index = 0
    
    override init(parent: Map<SourceType, ResultType>, observer: O, cancel: Disposable) {
        super.init(parent: parent, observer: observer, cancel: cancel)
    }
    override func performMap(element: SourceType) throws -> ResultType {
        return try _parent._selector2!(element, try incrementChecked(&_index))
    }
}

class Map<SourceType, ResultType>: Producer<ResultType> {
    typealias Selector1 = (SourceType) throws -> ResultType
    typealias Selector2 = (SourceType, Int) throws -> ResultType
    
    private let _source: Observable<SourceType>
    
    private let _selector1: Selector1?
    private let _selector2: Selector2?
    
    init(source: Observable<SourceType>, selector: Selector1) {
        _source = source
        _selector1 = selector
        _selector2 = nil
    }
    
    init(source: Observable<SourceType>, selector: Selector2) {
        _source = source
        _selector2 = selector
        _selector1 = nil
    }
    
    override func run<O: ObserverType where O.E == ResultType>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        if let _ = _selector1 {
            let sink = MapSink1(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribe(sink)
        }
        else {
            let sink = MapSink2(parent: self, observer: observer, cancel: cancel)
            setSink(sink)
            return _source.subscribe(sink)
        }
        
    }
}