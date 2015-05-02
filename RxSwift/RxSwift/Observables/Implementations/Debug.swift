//
//  Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Debug_<ElementType> : Sink<ElementType>, ObserverType {
    typealias Element = ElementType
    typealias Parent = Debug<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: ObserverOf<Element>, cancel: Disposable) {
        self.parent = parent
        super.init(observer: observer, cancel: cancel)
    }
    
    func on(event: Event<Element>) {
        let maxEventTextLength = 40
        let ellipsis = "..."
        
        let eventText = "\(event)"
        let eventNormalized = count(eventText) > maxEventTextLength
            ? prefix(eventText, maxEventTextLength / 2) + "..." + suffix(eventText, maxEventTextLength / 2)
            : eventText
        println("Event \(eventNormalized) @ observer \(self) [\(parent.identifier)]")
        self.observer.on(event)
    }
    
    override func dispose() {
        println("Disposing observer \(self) [\(parent.identifier)]")
        super.dispose()
    }
}

class Debug<Element> : Producer<Element> {
    let identifier: String
    
    let source: Observable<Element>
    
    init(identifier: String, source: Observable<Element>) {
        self.identifier = identifier
        self.source = source
    }
    
    override func run(observer: ObserverOf<Element>, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        let sink = Debug_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return self.source.subscribe(sink)
    }
}