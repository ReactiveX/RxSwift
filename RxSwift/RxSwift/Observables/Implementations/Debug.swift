//
//  Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Debug_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.Element
    typealias Parent = Debug<Element>
    
    let parent: Parent
    
    init(parent: Parent, observer: O, cancel: Disposable) {
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
        println("[\(parent.identifier)] -> Event \(eventNormalized)")
        trySend(observer, event)
    }
    
    override func dispose() {
        println("[\(parent.identifier)] dispose")
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
    
    override func run<O: ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        println("[\(identifier)] subscribed")
        let sink = Debug_(parent: self, observer: observer, cancel: cancel)
        setSink(sink)
        return self.source.subscribeSafe(sink)
    }
}