//
//  Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Debug_<O: ObserverType> : Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = Debug<Element>
    
    private let _parent: Parent
    private let _timestampFormatter = NSDateFormatter()
    
    init(parent: Parent, observer: O) {
        _parent = parent
        _timestampFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        super.init(observer: observer)
    }
    
    func on(event: Event<Element>) {
        let maxEventTextLength = 40
        let eventText = "\(event)"
        let eventNormalized = eventText.characters.count > maxEventTextLength
            ? String(eventText.characters.prefix(maxEventTextLength / 2)) + "..." + String(eventText.characters.suffix(maxEventTextLength / 2))
            : eventText

        print("\(_timestampFormatter.stringFromDate(NSDate())): [\(_parent._identifier)] -> Event \(eventNormalized)")
        forwardOn(event)
    }
    
    override func dispose() {
        print("\(_timestampFormatter.stringFromDate(NSDate())): [\(_parent._identifier)] dispose")
        super.dispose()
    }
}

class Debug<Element> : Producer<Element> {
    private let _identifier: String
    
    private let _source: Observable<Element>
    
    init(source: Observable<Element>, identifier: String) {
        _identifier = identifier
        _source = source
    }
    
    override func run<O: ObserverType where O.E == Element>(observer: O) -> Disposable {
        print("[\(_identifier)] subscribed")
        let sink = Debug_(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}