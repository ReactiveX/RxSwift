//
//  Dependencies.swift
//  WikipediaImageSearch
//
//  Created by carlos on 13/5/15.
//  Copyright (c) 2015 Carlos García. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

class Dependencies {
    
    static let sharedDependencies = Dependencies() // Singleton
    
    let URLSession = NSURLSession.sharedSession()
    let backgroundWorkScheduler: ImmediateScheduler
    let mainScheduler: SerialDispatchQueueScheduler
    let wireframe: Wireframe
    
    private init() {
        wireframe = DefaultWireframe()
        
        let operationQueue = NSOperationQueue()
        operationQueue.maxConcurrentOperationCount = 2
        if #available(iOS 8.0, *) {
            operationQueue.qualityOfService = NSQualityOfService.UserInitiated
        } else {
            // Fallback on earlier versions
        }
        backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
        
        mainScheduler = MainScheduler.sharedInstance
    }
    
}
