//
//  ObservableBinding.swift
//  RxSwift
//
//  Created by Sebastián Varela Basconi on 11/10/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

precedencegroup ObserverableBindingPrecedence {
    associativity: left
    higherThan: DisposableBindingPrecedence
}

infix operator <~ : ObserverableBindingPrecedence

/**
Subscribes the observable to the observer

- parameter observer: Who it receives events.
- parameter observable: Who it sends events.
- returns: Disposable
*/
public func <~ <Destination: ObserverType, Source: ObservableConvertibleType>(observer: Destination, observable: Source) -> Disposable where Source.Element == Destination.Element {
    return observable.asObservable().subscribe(observer)
}

public func ~> <Destination: ObserverType, Source: ObservableConvertibleType>(observable: Source, observer: Destination) -> Disposable where Source.Element == Destination.Element {
    return observer <~ observable
}

/**
 Subscribes the observable to the observer
 
 - parameter observer: Who it receives events.
 - parameter observable: Who it sends events.
 - returns: Disposable
 */

public func <~ <Source: ObservableConvertibleType>(observer: @escaping (Source.Element) -> Void, observable: Source) -> Disposable {
    return observable.asObservable().subscribe(onNext: (observer))
}

public func ~> <Source: ObservableConvertibleType>(observable: Source, observer: @escaping (Source.Element) -> Void) -> Disposable {
    return observer <~ observable
}
