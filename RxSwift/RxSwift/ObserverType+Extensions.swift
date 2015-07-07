//
//  ObserverType+Extensions.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/13/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation


public func send<O: ObserverType>(observer: O, _ event: Event<O.Element>) {
    observer.on(event)
}

public func sendNext<O: ObserverType>(observer: O, _ element: O.Element) {
    observer.on(.Next(element))
}

public func sendError<O: ObserverType>(observer: O, _ error: ErrorType) {
    observer.on(.Error(error))
}

public func sendCompleted<O: ObserverType>(observer: O) {
    observer.on(.Completed)
}

public func trySend<O: ObserverType>(observer: O?, _ event: Event<O.Element>) {
    observer?.on(event)
}

public func trySendNext<O: ObserverType>(observer: O?, _ element: O.Element) {
    observer?.on(.Next(element))
}

public func trySendError<O: ObserverType>(observer: O?, _ error: ErrorType) {
    observer?.on(.Error(error))
}

public func trySendCompleted<O: ObserverType>(observer: O?) {
    observer?.on(.Completed)
}

// this is temporary only

public func send<Element>(observer: ObserverOf<Element>, _ event: Event<Element>) {
    observer.on(event)
}

public func sendNext<Element>(observer: ObserverOf<Element>, _ element: Element) {
    observer.on(.Next(element))
}

public func sendError<Element>(observer: ObserverOf<Element>, _ error: ErrorType) {
    observer.on(.Error(error))
}

public func sendCompleted<Element>(observer: ObserverOf<Element>) {
    observer.on(.Completed)
}
