//
//  Cancelable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol Cancelable : Disposable {
    var disposed: Bool { get }
}