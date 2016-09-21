//
//  Foundation+Extensions.swift
//  Tests
//
//  Created by Krunoslav Zaher on 12/25/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(Linux)
func isMainThread() -> Bool {
    return RunLoop.current == RunLoop.main
}
#else
func isMainThread() -> Bool {
    return Thread.current.isMainThread
}
#endif
