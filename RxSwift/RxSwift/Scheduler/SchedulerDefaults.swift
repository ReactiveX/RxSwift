//
//  SchedulerDefaults.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

struct SchedulerDefaults {
    static var ConstantTimeOperations : ImmediateScheduler {
        get {
            return ImmediateSchedulerOnCurrentThread()
        }
    }
}