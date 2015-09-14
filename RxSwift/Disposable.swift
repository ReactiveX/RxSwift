//
//  Disposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Respresents disposable resource.
*/
public protocol Disposable {
    /**
    Dispose resource.
    */
    func dispose()
}