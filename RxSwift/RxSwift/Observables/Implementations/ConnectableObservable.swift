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
    
    var parent: ConnectableObservable<SourceType, ResultType>?
    var subscription: SingleAssignmentDisposable? = SingleAssignmentDisposable()
    
    init(parent: ConnectableObservable<SourceType, ResultType>) {
        self.parent = parent
    }
    
    func dispose() {
        if let parent = parent {
            parent.lock.performLocked {
                subscription!.dispose()
                subscription = nil
                self.parent!.connection = nil
                self.parent = nil
            }
        }
    }
}

class ConnectableObservable<SourceType, ResultType> : ConnectableObservableType<ResultType> {
    typealias ConnectionType = Connection<SourceType, ResultType>
    
    let subject: SubjectType<SourceType, ResultType>
    let source: Observable<SourceType>
    
    var lock = SpinLock()
    var connection: ConnectionType?
    
    init(source: Observable<SourceType>, subject: SubjectType<SourceType, ResultType>) {
        self.source = asObservable(source)
        self.subject = subject
        self.connection = nil
    }
    
    override func connect() -> Disposable {
        let (connection, connect) = self.lock.calculateLocked { () -> (Connection<SourceType, ResultType>, Bool) in
            if let connection = self.connection {
                return (connection, false)
            }
            else {
                self.connection = Connection(parent: self)
                return (self.connection!, true)
            }
        }

        if connect {
            let disposable = self.source.subscribeSafe(self.subject)
            connection.subscription!.disposable = disposable
        }
        
        return connection
    }
    
    override func subscribe<O : ObserverType where O.Element == ResultType>(observer: O) -> Disposable {
        return subject.subscribeSafe(observer)
    }
}