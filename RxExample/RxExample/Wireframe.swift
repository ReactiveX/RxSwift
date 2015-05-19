//
//  Wireframe.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if os(iOS)
import UIKit
#elseif os(OSX)
import Cocoa
#endif

protocol Wireframe {
    func openURL(URL: NSURL)
}


class DefaultWireframe: Wireframe {
    func openURL(URL: NSURL) {
        #if os(iOS)
            UIApplication.sharedApplication().openURL(URL)
        #elseif os(OSX)
            NSWorkspace.sharedWorkspace().openURL(URL)
        #endif
    }
}