//
//  Dependencies.swift
//  WikipediaImageSearch
//
//  Created by carlos on 13/5/15.
//  Copyright (c) 2015 Carlos García. All rights reserved.
//

import Foundation
import RxSwift

public class Dependencies {
	
	public static let sharedDependencies = Dependencies() // Singleton
	
	let API: WikipediaAPI
	let imageService: ImageService
	let backgroundWorkScheduler: ImmediateScheduler
	let mainScheduler: DispatchQueueScheduler
	let wireframe: Wireframe
	
	private init() {
		
		wireframe = DefaultWireframe()
		
		let operationQueue = NSOperationQueue()
		operationQueue.maxConcurrentOperationCount = 2
		operationQueue.qualityOfService = NSQualityOfService.UserInitiated
		backgroundWorkScheduler = OperationQueueScheduler(operationQueue: operationQueue)
		
		mainScheduler = MainScheduler.sharedInstance
		
		API = DefaultWikipediaAPI($: (
			URLSession: NSURLSession.sharedSession(),
			callbackScheduler: mainScheduler,
			backgroundScheduler: backgroundWorkScheduler
		))
		
		imageService = DefaultImageService($: (
			URLSession: NSURLSession.sharedSession(),
			imageDecodeScheduler: backgroundWorkScheduler,
			callbackScheduler: MainScheduler.sharedInstance
		))
		
	}
	
}
