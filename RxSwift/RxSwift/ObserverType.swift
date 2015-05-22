//
//  ObserverType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol ObserverType : class {
    /// The type of event to be written to this observer.
    typealias Element

    /// Send `event` to this observer.
    func on(event: Event<Element>)
}

public func sendNext<O: ObserverType, Element where O.Element == Element>(observer: O, element: Element) {
    observer.on(.Next(RxBox(element)))
}

public func sendError<O: ObserverType>(observer: O, error: ErrorType) {
    observer.on(.Error(error))
}

public func sendCompleted<O: ObserverType>(observer: O) {
    observer.on(.Completed)
}

// this is temporary only

public func sendNext<Element>(observer: ObserverOf<Element>, element: Element) {
    observer.on(.Next(RxBox(element)))
}

public func sendError<Element>(observer: ObserverOf<Element>, error: ErrorType) {
    observer.on(.Error(error))
}

public func sendCompleted<Element>(observer: ObserverOf<Element>) {
    observer.on(.Completed)
}
