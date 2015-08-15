//
//  ConnectableObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/1/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Connection<SourceType, ResultType> : Disposable {
    typealias SelfType = Connection<SourceType, ResultType>
    
    // state
    weak var parent: ConnectableObservable<SourceType, ResultType>?
    var subscription : Disposable?
    
    init(parent: ConnectableObservable<SourceType, ResultType>, subscription: Disposable) {
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

class ConnectableObservable<SourceType, ResultType> : ConnectableObservableType<ResultType> {
    typealias ConnectionType = Connection<SourceType, ResultType>
    
    let subject: SubjectType<SourceType, ResultType>
    let source: Observable<SourceType>
    
    var lock = NSRecursiveLock()
    var connection: ConnectionType?
    
    init(source: Observable<SourceType>, subject: SubjectType<SourceType, ResultType>) {
        self.source = source.asObservable()
        self.subject = subject
        self.connection = nil
    }
    
    override func connect() -> Disposable {
        return self.lock.calculateLocked {
            if let connection = self.connection {
                return connection
            }
            
            let disposable = self.source.subscribeSafe(self.subject)
            let connection = Connection(parent: self, subscription: disposable)
            self.connection = connection
            return connection
        }
    }
    
    override func subscribe<O : ObserverType where O.Element == ResultType>(observer: O) -> Disposable {
        return subject.subscribeSafe(observer)
    }
}