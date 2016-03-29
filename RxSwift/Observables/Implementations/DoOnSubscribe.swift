//
//  DoOnSubscribe.swift
//  Rx
//
//  Created by Kawajiri Ryoma on 3/29/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DoOnSubscribe_<O: ObserverType>: Sink<O>, ObserverType {
    typealias Element = O.E
    typealias Parent = DoOnSubscribe<Element>

    private let _parent: Parent

    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)

        do {
            try _parent._onSubscribe?()
        }
        catch let error {
            forwardOn(.Error(error))
            dispose()
        }
    }

    func on(event: Event<Element>) {
        forwardOn(event)
    }

    override func dispose() {
        do {
            try _parent._onUnsubscribe?()
        }
        catch let error {
            forwardOn(.Error(error))
        }
        super.dispose()
    }
}

class DoOnSubscribe<Element>: Producer<Element> {
    private let _onSubscribe: (() throws -> Void)?
    private let _onUnsubscribe: (() throws -> Void)?
    private let _source: Observable<Element>

    init(source: Observable<Element>, onSubscribe: (() throws -> Void)? = nil, onUnsubscribe: (() throws -> Void)? = nil ) {
        _onSubscribe = onSubscribe
        _onUnsubscribe = onUnsubscribe
        _source = source
    }

    override func run<O: ObserverType where O.E == Element>(observer: O) -> Disposable {
        let sink = DoOnSubscribe_(parent: self, observer: observer)
        sink.disposable = _source.subscribe(sink)
        return sink
    }
}
