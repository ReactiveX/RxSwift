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
    typealias LogURLRequest = (NSURLRequest) -> Bool
    
    #if DEBUG
    static var URLRequests: LogURLRequest = { _ in true }
    #else
    static var URLRequests: LogURLRequest = { _ in false }
    #endif
}