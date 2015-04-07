//
//  Wireframe.swift
//  Example
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit

protocol Wireframe {
    func openURL(URL: NSURL)
}


class DefaultWireframe: Wireframe {
    func openURL(URL: NSURL) {
        UIApplication.sharedApplication().openURL(URL)
    }
}