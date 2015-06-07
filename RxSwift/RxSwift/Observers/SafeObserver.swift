//
//  SafeObserver.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/7/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SafeObserver<O: ObserverType> : Observer<O.Element> {
    typealias Element = O.Element
    
    let observer: O
    let disposable: Disposable
    
    init(observer: O, disposable: Disposable) {
        self.observer = observer
        self.disposable = disposable
        super.init()
    }
    
    override func on(event: Event<Element>) {
        observer.on(event)
        
        switch event {
        case .Next:
            break
        case .Error:
            self.disposable.dispose()
        case .Completed:
            self.disposable.dispose()
        }
    }
}


func makeSafe<O: ObserverType>(observer: O, disposable: Disposable) -> Observer<O.Element> {
    if let anonymousObserver = observer as? AnonymousObserver<O.Element> {
        return anonymousObserver.makeSafe(disposable)
    }
    else {
        return SafeObserver(observer: observer, disposable: disposable)
    }
}