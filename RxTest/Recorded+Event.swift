//
//  Recorded+Event.swift
//  RxTest
//
//  Created by luojie on 2017/12/19.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
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

extension Recorded {
    
    /**
     Factory method for an array of recorded events, this may help if you don't want to declare the type of array:
     
     ```
     let correctMessages = Recorded.events(
         .next(210, 2),
         .next(220, 3),
         .next(230, 4),
         .next(240, 5),
         .completed(250),
     )
     ```
     
     is equivalent to:
     
     ```
     let correctMessages: [Recorded<Event<Int>>] = [
         .next(210, 2),
         .next(220, 3),
         .next(230, 4),
         .next(240, 5),
         .completed(250),
     ]
     ```
     
     - parameter recordedEvents: the Recorded events which will return
     */
    public static func events<T>(_ recordedEvents: Recorded<Event<T>>...) -> [Recorded<Event<T>>] where Value == Event<T> {
        return self.events(recordedEvents)
    }
    
    
    /**
     Factory method for an array of recorded events, this may help if you don't want to declare the type of array:
     
     ```
     let correctMessages = Recorded.events([
         .next(210, 2),
         .next(220, 3),
         .next(230, 4),
         .next(240, 5),
         .completed(250),
     ])
     ```
     
     is equivalent to:
     
     ```
     let correctMessages: [Recorded<Event<Int>>] = [
         .next(210, 2),
         .next(220, 3),
         .next(230, 4),
         .next(240, 5),
         .completed(250),
     ]
     ```
     
     - parameter recordedEvents: the Recorded events which will return
     */
    public static func events<T>(_ recordedEvents: [Recorded<Event<T>>]) -> [Recorded<Event<T>>] where Value == Event<T> {
        return recordedEvents
    }
}

