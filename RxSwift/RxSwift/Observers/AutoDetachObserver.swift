//
//  AutoDetachObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AutoDetachObserver<Element> : ObserverBase<Element> {
    private let observer : ObserverOf<Element>
    private let m : SingleAssignmentDisposable
    
    init(observer: ObserverOf<Element>) {
        self.observer = observer
        self.m = SingleAssignmentDisposable()
        
        super.init()
    }
    
    func setDisposable(disposable: Disposable) {
        m.setDisposable(disposable)
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