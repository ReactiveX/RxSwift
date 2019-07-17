//
//  RelayType.swift
//  RxRelay
//
//  Created by Anton Nazarov on 17/07/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

public protocol RelayType {
    /// The type of elements in sequence that relay can accept.
    associatedtype Element

    // Accepts `event` and emits it to subscribers
    func accept(_ event: Element)
}
