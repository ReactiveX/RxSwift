//
//  ObserverType+Extensions.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/13/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

@available(*, deprecated=2.0.0, message="Please use observer.on(event)")
public func send<O: ObserverType>(observer: O, _ event: Event<O.E>) {
    observer.on(event)
}

@available(*, deprecated=2.0.0, message="Please use observer.on(.Next(element))")
public func sendNext<O: ObserverType>(observer: O, _ element: O.E) {
    observer.on(.Next(element))
}

@available(*, deprecated=2.0.0, message="Please use observer.on(.Error(error))")
public func sendError<O: ObserverType>(observer: O, _ error: ErrorType) {
    observer.on(.Error(error))
}

@available(*, deprecated=2.0.0, message="Please use observer.on(.Completed)")
public func sendCompleted<O: ObserverType>(observer: O) {
    observer.on(.Completed)
}
