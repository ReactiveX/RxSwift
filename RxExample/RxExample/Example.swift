//
//  Example.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
    import UIKit
    typealias Image = UIImage
#elseif os(OSX)
    import Cocoa
    import AppKit
    typealias Image = NSImage
#endif

let MB = 1024 * 1024

extension String {
    func toFloat() -> Float? {
        let numberFormatter = NSNumberFormatter()
        return numberFormatter.numberFromString(self)?.floatValue
    }
    
    func toDouble() -> Double? {
        let numberFormatter = NSNumberFormatter()
        return numberFormatter.numberFromString(self)?.doubleValue
    }
}

