//
//  Dependencies.swift
//  RxExample
//
//  Created by carlos on 13/5/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift

import class Foundation.URLSession
import class Foundation.OperationQueue
import enum Foundation.QualityOfService

class Dependencies {
    
    private static let _URLSession = Foundation.URLSession.shared
    private static let _backgroundWorkScheduler: ImmediateSchedulerType = {
        let operationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        operationQueue.qualityOfService = QualityOfService.userInitiated
        return OperationQueueScheduler(operationQueue: operationQueue)
    }()
    private static let _mainScheduler: SerialDispatchQueueScheduler = MainScheduler.instance
    private static let _wireframe: Wireframe = DefaultWireframe()
    private static let _reachabilityService: ReachabilityService = try! DefaultReachabilityService() // try! is only for simplicity sake
    
    let URLSession: URLSession = Dependencies._URLSession
    let backgroundWorkScheduler: ImmediateSchedulerType = Dependencies._backgroundWorkScheduler
    let mainScheduler: SerialDispatchQueueScheduler = Dependencies._mainScheduler
    let wireframe: Wireframe = Dependencies._wireframe
    let reachabilityService: ReachabilityService = Dependencies._reachabilityService
    
}
