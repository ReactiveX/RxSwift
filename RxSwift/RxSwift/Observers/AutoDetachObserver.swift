//
//  AutoDetachObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AutoDetachObserver<O: ObserverType> : ObserverBase<O.Element> {
    private var observer : O?
    private let m : SingleAssignmentDisposable
    private var observerLock = SpinLock()
    
    init(observer: O) {
        self.observer = observer
        self.m = SingleAssignmentDisposable()
        
        super.init()
    }
    
    func setDisposable(disposable: Disposable) {
        m.disposable = disposable
    }
    
    override func onCore(event: Event<Element>) {
        let observer = self.observerLock.calculateLocked {
            return self.observer
        }
        
        switch event {
        case .Next:
            trySend(observer, event)
        case .Completed: fallthrough
        case .Error:
            trySend(observer, event)
            dispose()
        }
    }
    
    override func dispose() {
        super.dispose()
        m.dispose()
        observerLock.performLocked {
            self.observer = nil
        }
    }
}