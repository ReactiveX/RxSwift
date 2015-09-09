//
//  AnonymousObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class AnonymousObserver<ElementType> : ObserverBase<ElementType> {
    typealias Element = ElementType
    
    typealias EventHandler = Event<Element> -> Void
    
    private let eventHandler : EventHandler
    
    init(_ eventHandler: EventHandler) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        self.eventHandler = eventHandler
    }

    func makeSafe(disposable: Disposable) -> AnonymousSafeObserver<Element> {
        return AnonymousSafeObserver(self.eventHandler, disposable: disposable)
    }

    override func onCore(event: Event<Element>) {
        return self.eventHandler(event)
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}

class AnonymousSafeObserver<ElementType> : Observer<ElementType> {
    typealias Element = ElementType
    
    typealias EventHandler = Event<Element> -> Void
    
    private let eventHandler : EventHandler
    private let disposable: Disposable

    var stopped: Int32 = 0

    init(_ eventHandler: EventHandler, disposable: Disposable) {
#if TRACE_RESOURCES
        OSAtomicIncrement32(&resourceCount)
#endif
        self.eventHandler = eventHandler
        self.disposable = disposable
    }
    
    override func on(event: Event<Element>) {
        switch event {
        case .Next:
            if stopped == 0 {
                self.eventHandler(event)
            }
        case .Error:
            if OSAtomicCompareAndSwapInt(0, 1, &stopped) {
                self.eventHandler(event)
                self.disposable.dispose()
            }
        case .Completed:
            if OSAtomicCompareAndSwapInt(0, 1, &stopped) {
                self.eventHandler(event)
                self.disposable.dispose()
            }
        }
    }
    
#if TRACE_RESOURCES
    deinit {
        OSAtomicDecrement32(&resourceCount)
    }
#endif
}