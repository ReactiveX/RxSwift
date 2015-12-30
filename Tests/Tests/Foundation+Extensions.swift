//
//  Foundation+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

func isMainThread() -> Bool {
    return NSThread.currentThread().isMainThread
}