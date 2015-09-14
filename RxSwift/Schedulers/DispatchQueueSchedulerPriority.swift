//
//  DispatchQueueSchedulerPriority.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/5/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Identifies one of the global concurrent dispatch queues with specified priority.
*/
public enum DispatchQueueSchedulerPriority {
    
    /**
    Identifies global dispatch queue with `DISPATCH_QUEUE_PRIORITY_HIGH`
    */
    case High
    
    /**
    Identifies global dispatch queue with `DISPATCH_QUEUE_PRIORITY_DEFAULT`
    */
    case Default
    
    /**
    Identifies global dispatch queue with `DISPATCH_QUEUE_PRIORITY_LOW`
    */
    case Low
}
