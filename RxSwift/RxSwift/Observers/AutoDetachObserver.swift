//
//  AutoDetachObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AutoDetachObserver<O: ObserverType> : ObserverBase<O.Element> {
    private let observer : O
    private let m : SingleAssignmentDisposable
    
    init(observer: O) {
        self.observer = observer
        self.m = SingleAssignmentDisposable()
        
        super.init()
    }
    
    func setDisposable(disposable: Disposable) {
        m.disposable = disposable
    }
    
    override func onCore(event: Event<Element>) {
        switch event {
        case .Next:
            observer.on(event)
        case .Completed: fallthrough
        case .Error:
            observer.on(event)
            dispose()
        }
    }
    
    override func dispose() {
        super.dispose()
        m.dispose()
    }
}