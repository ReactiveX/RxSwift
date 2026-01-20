//
//  Platform.Darwin.swift
//  Platform
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import Darwin
import Foundation

extension Thread {
    static func setThreadLocalStorageValue(_ value: (some AnyObject)?, forKey key: NSCopying) {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary

        if let newValue = value {
            threadDictionary[key] = newValue
        } else {
            threadDictionary[key] = nil
        }
    }

    static func getThreadLocalStorageValueForKey<T>(_ key: NSCopying) -> T? {
        let currentThread = Thread.current
        let threadDictionary = currentThread.threadDictionary

        return threadDictionary[key] as? T
    }
}

#endif
