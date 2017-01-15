//
//  main.swift
//  Tests
//
//  Created by Krunoslav Zaher on 9/26/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
#if !SWIFT_PACKAGE
import RxCocoa
#endif
import AppKit
import CoreLocation

let bechmarkTime = true

func allocation() {
    
}

repeat {
    compareTwoImplementations(benchmarkTime: true, benchmarkMemory: false, first: {
        let lock = RecursiveLock()
        for i in 0 ..< 1000 {
            lock.lock()
            lock.unlock()
        }
    }, second: {
        let lock = RecursiveLock()
        for i in 0 ..< 1000 {
            lock.lock()
            lock.unlock()
        }
    })
} while true
