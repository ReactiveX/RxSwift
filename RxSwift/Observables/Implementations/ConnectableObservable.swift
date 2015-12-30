//
//  ConnectableObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
 Represents an observable wrapper that can be connected and disconnected from its underlying observable sequence.
*/
public class ConnectableObservable<Element>
    : Observable<Element>
    , ConnectableObservableType {

    /**
     Connects the observable wrapper to its source. All subscribed observers will receive values from the underlying observable sequence as long as the connection is established.
     
     - returns: Disposable used to disconnect the observable wrapper from its source, causing subscribed observer to stop receiving values from the underlying observable sequence.
    */
    public func connect() -> Disposable {
        abstractMethod()
    }
}

class Connection<S: SubjectType> : Disposable {
    
    // state
    private weak var _parent: ConnectableObservableAdapter<S>?
    private var _subscription : Disposable?
    
    init(parent: ConnectableObservableAdapter<S>, subscription: Disposable) {
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

class ConnectableObservableAdapter<S: SubjectType>
    : ConnectableObservable<S.E> {
    typealias ConnectionType = Connection<S>
    
    private let _subject: S
    private let _source: Observable<S.SubjectObserverType.E>
    
    private let _lock = NSRecursiveLock()
    
    // state
    private var _connection: ConnectionType?
    
    init(source: Observable<S.SubjectObserverType.E>, subject: S) {
        _source = source
        _subject = subject
        _connection = nil
    }
    
    override func connect() -> Disposable {
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
    
    override func subscribe<O : ObserverType where O.E == S.E>(observer: O) -> Disposable {
        return _subject.subscribe(observer)
    }
}