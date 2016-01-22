//
//  GroupBy.swift
//  Rx
//
//  Created by Tomi Koskinen on 01/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class GroupedObservableImpl<Key, Element> : GroupedObservable<Key, Element> {
    private var _subject: PublishSubject<Element>
    private var _refCount: RefCountDisposable
    
    init(key: Key, subject: PublishSubject<Element>, refCount: RefCountDisposable) {
        _subject = subject
        _refCount = refCount
        super.init(key: key)
    }
    
    override func subscribe<O: ObserverType where O.E == E>(observer: O) -> Disposable {
        let release = _refCount.retain()
        let subscription = _subject.subscribe(observer)
        return StableCompositeDisposable.create(release, subscription)
    }
    
    override func asObservable() -> GroupedObservable<Key, Element>{
        return self
    }
}


class GroupBySink<Key: Hashable, Element, O: ObserverType where O.E == GroupedObservable<Key,Element>>
    : Sink<O>
    , ObserverType {
    typealias ResultType = O.E
    typealias Parent = GroupBy<Key, Element>

    private let _parent: Parent
    private let _groupDisposable = CompositeDisposable()
    private var _refCountDisposable: RefCountDisposable!
    private var _groupedSubjectTable: [Key: PublishSubject<Element>]
    
    init(parent: Parent, observer: O) {
        _parent = parent
        _groupedSubjectTable = [Key: PublishSubject<Element>]()
        super.init(observer: observer)
    }
    
    func run() -> Disposable {
        _refCountDisposable = RefCountDisposable(disposable: _groupDisposable)
        
        _groupDisposable.addDisposable(_parent._source.subscribeSafe(self))
        
        return _refCountDisposable
    }
    
    private func onGroupEvent(key: Key, value: Element) {
        if let writer = _groupedSubjectTable[key] {
            writer.on(.Next(value))
        } else {
            let writer = PublishSubject<Element>()
            _groupedSubjectTable[key] = writer
            
            let group = GroupedObservableImpl(key: key, subject: writer, refCount: _refCountDisposable)
            
            forwardOn(.Next(group.asObservable()))
            writer.on(.Next(value))
        }
    }
    
    func on(event: Event<Element>) {
        switch event {
        case .Next(let value):
            do {
                let groupKey = try _parent._selector(value)
                onGroupEvent(groupKey, value: value)
            }
            catch let e {
                forwardOnGroups(.Error(e))
                forwardOn(.Error(e))
                _groupDisposable.dispose()
                dispose()
                return
            }
        case .Error(let error):
            forwardOnGroups(.Error(error))
            forwardOn(.Error(error))
            dispose()
        case .Completed:
            forwardOnGroups(.Completed)
            forwardOn(.Completed)
            dispose()
        }
    }
    
    func forwardOnGroups(event: Event<Element>) {
        for (_, writer) in _groupedSubjectTable {
            writer.on(event)
        }
    }
}

class GroupBy<Key: Hashable, Element>: Producer<GroupedObservable<Key,Element>> {
    typealias KeySelector = (Element) throws -> Key

    private let _source: Observable<Element>
    private let _selector: KeySelector
    
    init(source: Observable<Element>, selector: KeySelector) {
        _source = source
        _selector = selector
    }
    
    override func run<O: ObserverType where O.E == GroupedObservable<Key,Element>>(observer: O) -> Disposable {
        let sink = GroupBySink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}