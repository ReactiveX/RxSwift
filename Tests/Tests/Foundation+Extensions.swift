//
//  Foundation+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//
//

import Foundation

func isMainThread() -> Bool {
    return NSThread.currentThread().isMainThread
}