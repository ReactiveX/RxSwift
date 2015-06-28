//
//  RxCocoa.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

public enum RxCocoaError : Int {
    case Unknown = 0
    case NetworkError = 1
    case InvalidOperation = 2
}

let defaultHeight: CGFloat = -1

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

func handleVoidObserverResult(result: RxResult<Void>) {
    handleObserverResult(result)
}

func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

func bindingErrorToInterface(error: ErrorType) {
#if DEBUG
    rxFatalError("Binding error to UI: \(error)")
#endif
}

// There are certain kinds of errors that shouldn't be silenced, but it could be weird to crash the app because of them.
// DEBUG -> crash the app
// RELEASE -> log to console
func rxPossiblyFatalError(error: String) {
#if DEBUG
    rxFatalError(error)
#else
    println("[RxSwift]: \(error)")
#endif
}

func rxFatalErrorAndDontReturn<T>(lastMessage: String) -> T {
    rxFatalError(lastMessage)
    return (nil as T!)!
}

func rxAbstractMethod<T>() -> T {
    return rxFatalErrorAndDontReturn("Abstract method")
}

func handleObserverResult<T>(result: RxResult<T>) {
    switch result {
    case .Failure(let error):
        print("Error happened \(error)")
        rxFatalError("Error '\(error)' happened while ");
    default: break
    }
}

// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrFatalError<T>(value: AnyObject!) -> T {
    let result: RxResult<T> = castOrFail(value)
    
    if result.isFailure {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result.get()
}