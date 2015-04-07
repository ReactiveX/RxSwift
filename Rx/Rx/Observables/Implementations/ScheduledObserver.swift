//
//  ScheduledObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

enum ScheduledState: Int {
    case Stopped = 0
    case Running = 1
    case Pending = 2
    case Faulted = 9
}

public class ScheduledObserver<Element> : ObserverBase<Element> {
    
}