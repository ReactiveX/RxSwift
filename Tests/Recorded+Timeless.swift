//
//  Recorded+Timeless.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxTest
import RxSwift

extension Recorded {
    
    public static func next<T>(_ element: T) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: 0, value: .next(element))
    }
    
    public static func completed<T>(_ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: 0, value: .completed)
    }
    
    public static func error<T>(_ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: 0, value: .error(error))
    }
}

func next<T>(_ value: T) -> Recorded<Event<T>> {
    return Recorded(time: 0, value: .next(value))
}

func completed<T>() -> Recorded<Event<T>> {
    return Recorded(time: 0, value: .completed)
}

func error<T>(_ error: Swift.Error) -> Recorded<Event<T>> {
    return Recorded(time: 0, value: .error(error))
}
