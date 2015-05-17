//
//  RxCocoa.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public enum RxCocoaError : Int {
    case Unknown = 0
    case NetworkError = 1
    case InvalidOperation = 2
}

public let RxCocoaErrorDomain = "RxCocoaError"

public let RxCocoaErrorHTTPResponseKey = "RxCocoaErrorHTTPResponseKey"

func rxError(errorCode: RxCocoaError, message: String) -> NSError {
    return NSError(domain: RxCocoaErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
}

func rxError(errorCode: RxCocoaError, message: String, userInfo: NSDictionary) -> NSError {
    let mutableDictionary = NSMutableDictionary(dictionary: userInfo as! [NSObject : AnyObject])
    mutableDictionary[NSLocalizedDescriptionKey] = message
    // swift compiler :(
    let resultInfo: [NSObject: AnyObject] = (userInfo as NSObject) as! [NSObject: AnyObject]
    return NSError(domain: RxCocoaErrorDomain, code: Int(errorCode.rawValue), userInfo: resultInfo)
}

func removingObserverFailed() {
    rxFatalError("Removing observer for key failed")
}

func handleVoidObserverResult(result: Result<Void>) {
    handleObserverResult(result)
}

func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

func handleObserverResult<T>(result: Result<T>) {
    switch result {
    case .Error(let error):
        print("Error happened \(error)")
        rxFatalError("Error '\(error)' happened while ");
    default: break
    }
}