//
//  SynchronizedUnsubscribeType.swift
//  Rx
//
//  Created by Krunoslav Zaher on 10/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol SynchronizedUnsubscribeType : class, Lock {
    typealias DisposeKey

    func _synchronized_unsubscribe(disposeKey: DisposeKey)
}

extension SynchronizedUnsubscribeType {
    func synchronizedUnsubscribe(disposeKey: DisposeKey) {
        lock(); defer { unlock() }
        _synchronized_unsubscribe(disposeKey)
    }
}