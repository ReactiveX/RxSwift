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

func next<T>(_ value: T) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .next(value))
}

func completed<T>() -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .completed)
}

func error<T>(_ error: Swift.Error) -> Recorded<Event<T>> {
    return Recorded(time: 0, event: .error(error))
}
