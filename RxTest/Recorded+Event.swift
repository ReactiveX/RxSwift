//
//  Recorded+Event.swift
//  Rx
//
//  Created by luojie on 2017/11/30.
//  Copyright © 2017年 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension Recorded {
    
    /**
     Factory method for an `.next` event recorded at a given time with a given value.
     
     - parameter time: Recorded virtual time the `.next` event occurs.
     - parameter element: Next sequence element.
     - returns: Recorded event in time.
     */
    public static func next<T>(_ time: TestTime, _ element: T) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .next(element))
    }
    
    /**
     Factory method for an `.completed` event recorded at a given time.
     
     - parameter time: Recorded virtual time the `.completed` event occurs.
     - parameter type: Sequence elements type.
     - returns: Recorded event in time.
     */
    public static func completed<T>(_ time: TestTime, _ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .completed)
    }
    
    /**
     Factory method for an `.error` event recorded at a given time with a given error.
     
     - parameter time: Recorded virtual time the `.completed` event occurs.
     */
    public static func error<T>(_ time: TestTime, _ error: Swift.Error, _ type: T.Type = T.self) -> Recorded<Event<T>> where Value == Event<T> {
        return Recorded(time: time, value: .error(error))
    }
}
