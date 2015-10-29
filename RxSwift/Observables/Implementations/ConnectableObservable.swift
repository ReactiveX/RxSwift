//
//  ConnectableObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Connection<S: SubjectType> : Disposable {
    
    // state
    private weak var _parent: ConnectableObservable<S>?
    private var _subscription : Disposable?
    
    init(parent: ConnectableObservable<S>, subscription: Disposable) {
        _parent = parent
        _subscription = subscription
    }
    
    func dispose() {
        guard let parent = _parent else { return }
        
        parent._lock.performLocked {
            guard let oldSubscription = _subscription else {
                return
            }
            
            _subscription = nil
            if _parent?._connection === self {
                parent._connection = nil
            }
            _parent = nil
            
            oldSubscription.dispose()
        }
    }
}

public class ConnectableObservable<S: SubjectType> : Observable<S.E>, ConnectableObservableType {
    typealias ConnectionType = Connection<S>
    
    private let _subject: S
    private let _source: Observable<S.SubjectObserverType.E>
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _connection: ConnectionType?
    
    public init(source: Observable<S.SubjectObserverType.E>, subject: S) {
        _source = source
        _subject = subject
        _connection = nil
    }
    
    public func connect() -> Disposable {
        return _lock.calculateLocked {
            if let connection = _connection {
                return connection
            }
            
            let disposable = _source.subscribe(_subject.asObserver())
            let connection = Connection(parent: self, subscription: disposable)
            _connection = connection
            return connection
        }
    }
    
    public override func subscribe<O : ObserverType where O.E == S.E>(observer: O) -> Disposable {
        return _subject.subscribe(observer)
    }
}