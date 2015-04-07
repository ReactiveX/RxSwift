//
//  WhereObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/17/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class WhereObserver<Element>: ObserverBase<Element> {
    typealias Predicate = (Element) -> Result<Bool>
    
    let observer: ObserverOf<Element>
    let predicate: Predicate
    
    init(observer: ObserverOf<Element>, predicate: Predicate) {
        self.observer = observer
        self.predicate = predicate
    }
    
    override func onCore(event: Event<Element>) -> Result<Void> {
        switch event {
        case .Next(let value):
            return (predicate(value.value) >>! { e in
                return self.observer.on(.Error(e)) >>> { .Error(e) }
            }) >== { satisfies in
                return satisfies
                    ? self.observer.on(event)
                    : SuccessResult
            }
        case .Completed: fallthrough
        case .Error: return observer.on(event)
        }
    }
}

class WhereObservable<Element> : ObservableBase<Element> {
    typealias Predicate = (Element) -> Result<Bool>
    
    let source: Observable<Element>
    let predicate: Predicate
    
    init(source: Observable<Element>, predicate: Predicate) {
        self.source = source
        self.predicate = predicate
    }
    
    func compose(predicate: Predicate) -> WhereObservable {
        // too slow
        return WhereObservable(source: source, predicate: { lift({ $0 && $1 }) (self.predicate($0), predicate($0)) })
    }
    
    override func subscribeCore(observer: ObserverOf<Element>) -> Result<Disposable> {
        return source.subscribe(ObserverOf(WhereObserver(observer: observer, predicate: predicate)))
    }
}