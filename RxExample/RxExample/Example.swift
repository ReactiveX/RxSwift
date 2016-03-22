//
//  Example.swift
//  Example
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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

func exampleError(error: String, location: String = "\(#file):\(#line)") -> NSError {
    return NSError(domain: "ExampleError", code: -1, userInfo: [NSLocalizedDescriptionKey: "\(location): \(error)"])
}

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

func showAlert(message: String) {
    #if os(iOS)
        UIAlertView(title: "RxExample", message: message, delegate: nil, cancelButtonTitle: "OK").show()
    #elseif os(OSX)
        let alert = NSAlert()
        alert.messageText = message
        alert.runModal()
    #endif
}