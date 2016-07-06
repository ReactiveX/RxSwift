//
//  DispatchQueueSchedulerQOS.swift
//  RxSwift
//
//  Created by John C. "Hsoi" Daub on 12/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

/**
Identifies one of the global concurrent dispatch queues with specified quality of service class.
*/
public enum DispatchQueueSchedulerQOS {
    
    /**
    Identifies global dispatch queue with `QOS_CLASS_USER_INTERACTIVE`
    */
    case userInteractive
    
    /**
    Identifies global dispatch queue with `QOS_CLASS_USER_INITIATED`
    */
    case userInitiated
    
    /**
    Identifies global dispatch queue with `QOS_CLASS_DEFAULT`
    */
    case `default`

    /**
     Identifies global dispatch queue with `QOS_CLASS_UTILITY`
     */
    case utility
    
    /**
     Identifies global dispatch queue with `QOS_CLASS_BACKGROUND`
     */
    case background
}


@available(iOS 8, OSX 10.10, *)
extension DispatchQueueSchedulerQOS {
    var QOSClass: DispatchQueueAttributes {
        switch self {
        case .userInteractive: return .qosUserInteractive
        case .userInitiated:   return .qosUserInitiated
        case .default:         return .qosDefault
        case .utility:         return .qosUtility
        case .background:      return .qosBackground
        }
    }
}
