//
//  RxCocoa.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
#if os(iOS)
    import UIKit
#endif

public enum RxCocoaError : Int {
    case Unknown = 0
    case NetworkError = 1
    case InvalidOperation = 2
    case KeyPathInvalid = 3
}

let defaultHeight: CGFloat = -1

public let RxCocoaErrorDomain = "RxCocoaError"

public let RxCocoaErrorHTTPResponseKey = "RxCocoaErrorHTTPResponseKey"

func rxError(errorCode: RxCocoaError, _ message: String) -> NSError {
    return NSError(domain: RxCocoaErrorDomain, code: errorCode.rawValue, userInfo: [NSLocalizedDescriptionKey: message])
}

#if !RELEASE
public func _rxError(errorCode: RxCocoaError, message: String, userInfo: NSDictionary) -> NSError {
    return rxError(errorCode, message: message, userInfo: userInfo)
}
#endif

func rxError(errorCode: RxCocoaError, message: String, userInfo: NSDictionary) -> NSError {
    var resultInfo: [NSObject: AnyObject] = [:]
    resultInfo[NSLocalizedDescriptionKey] = message
    for k in userInfo.allKeys {
        resultInfo[k as! NSObject] = userInfo[k as! NSCopying]
    }
    return NSError(domain: RxCocoaErrorDomain, code: Int(errorCode.rawValue), userInfo: resultInfo)
}

func handleVoidObserverResult(result: RxResult<Void>) {
    handleObserverResult(result)
}

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
#if DEBUG
    rxFatalError(error)
#else
    print(error)
#endif
}

func rxAbstractMethodWithMessage<T>(message: String) -> T {
    return rxFatalErrorAndDontReturn(message)
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

func castOrFatalError<T>(value: AnyObject!, message: String) -> T {
    let result: RxResult<T> = castOrFail(value)
    
    if result.isFailure {
        rxFatalError(message)
    }
    
    return result.get()
}

func castOrFatalError<T>(value: AnyObject!) -> T {
    let result: RxResult<T> = castOrFail(value)
    
    if result.isFailure {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result.get()
}

// Error messages {

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

// }


func rxFatalErrorAndDontReturn<T>(lastMessage: String) -> T {
    rxFatalError(lastMessage)
    return (nil as T!)!
}

#if !RX_NO_MODULE

func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

extension NSObject {
    func rx_synchronized<T>(@noescape action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}

func removingObserverFailed() {
    rxFatalError("Removing observer for key failed")
}
    
#endif
