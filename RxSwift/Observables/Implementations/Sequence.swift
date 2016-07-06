//
//  Sequence.swift
//  Rx
//
//  Created by Krunoslav Zaher on 11/14/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class ObservableSequenceSink<O: ObserverType> : Sink<O> {
    typealias Parent = ObservableSequence<O.E>

    private let _parent: Parent

    init(parent: Parent, observer: O) {
        _parent = parent
        super.init(observer: observer)
    }

    func run() -> Disposable {
        return _parent._scheduler!.scheduleRecursive((0, _parent._elements)) { (state, recurse) in
            if state.0 < state.1.count {
                self.forwardOn(.next(state.1[state.0]))
                recurse((state.0 + 1, state.1))
            }
            else {
                self.forwardOn(.completed)
            }
        }
    }
}

class ObservableSequence<E> : Producer<E> {
    private let _elements: [E]
    private let _scheduler: ImmediateSchedulerType?

    init(elements: [E], scheduler: ImmediateSchedulerType?) {
        _elements = elements
        _scheduler = scheduler
    }

    override func subscribe<O : ObserverType where O.E == E>(_ observer: O) -> Disposable {
        // optimized version without scheduler
        guard _scheduler != nil else {
            for element in _elements {
                observer.on(.next(element))
            }
            
            observer.on(.completed)
            return NopDisposable.instance
        }

        let sink = ObservableSequenceSink(parent: self, observer: observer)
        sink.disposable = sink.run()
        return sink
    }
}
