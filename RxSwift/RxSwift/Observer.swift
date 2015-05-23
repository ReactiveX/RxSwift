//
//  Observer.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/23/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// This is a base class for all of the internal observers/sinks
class Observer<ElementType> : ObserverType {
    typealias Element = ElementType

    func on(event: Event<Element>) {
        return abstractMethod()
    }
    
    class func normalize<O: ObserverType where O.Element == Element>(observer: O) -> Observer<Element> {
        if let observer = observer as? Observer<Element> {
            return observer
        }
        else {
            return ObserverAdapter(observer: observer)
        }
    }
}

class ObserverAdapter<O: ObserverType> : Observer<O.Element> {
    let observer: O
    
    init(observer: O) {
        self.observer = observer
    }
    
    override func on(event: Event<Element>) {
        self.observer.on(event)
    }
}