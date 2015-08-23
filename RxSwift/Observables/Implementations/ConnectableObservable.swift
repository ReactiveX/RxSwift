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
    weak var parent: ConnectableObservable<S>?
    var subscription : Disposable?
    
    init(parent: ConnectableObservable<S>, subscription: Disposable) {
        self.parent = parent
        self.subscription = subscription
    }
    
    func dispose() {
        guard let parent = self.parent else { return }
        
        parent.lock.performLocked {
            guard let oldSubscription = self.subscription else {
                return
            }
            
            self.subscription = nil
            self.parent!.connection = nil
            self.parent = nil
            
            oldSubscription.dispose()
        }
    }
}

public class ConnectableObservable<S: SubjectType> : Observable<S.E>, ConnectableObservableType {
    typealias ConnectionType = Connection<S>
    
    let subject: S
    let source: Observable<S.SubjectObserverType.E>
    
    var lock = NSRecursiveLock()
    var connection: ConnectionType?
    
    public init(source: Observable<S.SubjectObserverType.E>, subject: S) {
        self.source = AsObservable(source: source)
        self.subject = subject
        self.connection = nil
    }
    
    public func connect() -> Disposable {
        return self.lock.calculateLocked {
            if let connection = self.connection {
                return connection
            }
            
            let disposable = self.source.subscribeSafe(self.subject.asObserver())
            let connection = Connection(parent: self, subscription: disposable)
            self.connection = connection
            return connection
        }
    }
    
    public override func subscribe<O : ObserverType where O.E == S.E>(observer: O) -> Disposable {
        return subject.subscribeSafe(observer)
    }
}