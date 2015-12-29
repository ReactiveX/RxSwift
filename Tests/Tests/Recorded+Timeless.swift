//
//  Recorded+Timeless.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxTests
import RxSwift

func next<T>(value: T) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Next(value))
}

func completed<T>() -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Completed)
}

func error<T>(error: ErrorType) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .Error(error))
}