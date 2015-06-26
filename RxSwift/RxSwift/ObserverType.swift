//
//  ObserverType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol ObserverType : class {
    /// The type of event to be written to this observer.
    typealias Element

    /// Send `event` to this observer.
    func on(event: Event<Element>)
}

