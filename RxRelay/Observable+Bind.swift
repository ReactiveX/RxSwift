//
//  Observable+Bind.swift
//  RxRelay
//
//  Created by Shai Mishali on 09/04/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift

extension ObservableType {
    /**
     Creates new subscription and sends elements to relay(s).
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     - parameter to: Target relays for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind<Relay: RelayType>(to relays: Relay...) -> Disposable where Relay.Element == Element {
        return bind(to: relays)
    }

    /**
     Creates new subscription and sends elements to relay(s).

     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.

     - parameter to: Target relays for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    public func bind<Relay: RelayType>(to relays: Relay...) -> Disposable where Relay.Element == Optional<Element> {
        return self.map(Optional.some).bind(to: relays)
    }

    /**
     Creates new subscription and sends elements to relay(s).
     In case error occurs in debug mode, `fatalError` will be raised.
     In case error occurs in release mode, `error` will be logged.
     - parameter to: Target relays for sequence elements.
     - returns: Disposable object that can be used to unsubscribe the observer.
     */
    private func bind<Relay: RelayType>(to relays: [Relay]) -> Disposable where Relay.Element == Element {
        return subscribe { e in
            switch e {
            case let .next(element):
                relays.forEach {
                    $0.accept(element)
                }
            case let .error(error):
                rxFatalErrorInDebug("Binding error to relay: \(error)")
            case .completed:
                break
            }
        }
    }
}
