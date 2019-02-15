//
//  DispatchQueue+Extensions.swift
//  Platform
//
//  Created by Krunoslav Zaher on 10/22/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Dispatch
import Foundation

extension DispatchQueue {
    static var isMain: Bool {
        return Thread.isMainThread
    }
}
