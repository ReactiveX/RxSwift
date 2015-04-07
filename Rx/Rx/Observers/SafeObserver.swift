//
//  SafeObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class SafeObserver<ElementType> : ObserverClassType {
    typealias Element = ElementType
    
    let observer: ObserverOf<Element>
    let disposable: Disposable
    
    class func create(observer: ObserverOf<Element>, disposable: Disposable) -> ObserverOf<Element> {
        if let anonymousObserver: AnonymousObserver<Element> = observer.ofType() {
            let anonymousSafeObserver: AnonymousSafeObserver<Element> = anonymousObserver.makeSafe(disposable)
            return ObserverOf(anonymousSafeObserver)
        }
        else {
            let safeObserver: SafeObserver<Element> = SafeObserver<Element>(observer: observer, disposable: disposable)
            return ObserverOf(safeObserver)
        }
    }
    
    init(observer: ObserverOf<Element>, disposable: Disposable) {
        self.observer = observer
        self.disposable = disposable
#if DEBUG
        OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    func on(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next:
            return self.observer.on(event) >>! { e  in
                self.disposable.dispose()
                return .Error(e)
            }
        case .Completed: fallthrough
        case .Error:
            let result = self.observer.on(event)
            self.disposable.dispose()
            return result
        }
    }
    
    deinit {
#if DEBUG
    OSAtomicDecrement32(&resourceCount)
#endif
    }
}