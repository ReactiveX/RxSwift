//
//  Logging.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/3/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// read your own configuration
struct Logging {
    #if DEBUG
    static let URLRequests = true
    #else
    static let URLRequests = false
    #endif
}