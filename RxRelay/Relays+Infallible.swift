//
//  Relays+Infallible.swift
//  RxSwift
//
//  Created by Mikhail Markin on 18/06/2022.
//  Copyright © 2022 Krunoslav Zaher. All rights reserved.
//

public extension BehaviorRelay {
    /// Convert to an `Infallible`
    ///
    /// - returns: `Infallible<Element>`
    func asInfallible() -> Infallible<Element> {
        Infallible(self.asObservable())
    }
}

public extension PublishRelay {
    /// Convert to an `Infallible`
    ///
    /// - returns: `Infallible<Element>`
    func asInfallible() -> Infallible<Element> {
        Infallible(self.asObservable())
    }
}

public extension ReplayRelay {
    /// Convert to an `Infallible`
    ///
    /// - returns: `Infallible<Element>`
    func asInfallible() -> Infallible<Element> {
        Infallible(self.asObservable())
    }
}
