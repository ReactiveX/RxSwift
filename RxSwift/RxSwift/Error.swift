//
//  Error.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

let RxErrorDomain       = "RxErrorDomain"
let RxCompositeFailures = "RxCompositeFailures"

public enum RxErrorCode : Int {
    case Unknown   = 0
    case Cast      = 2
    case Disposed  = 3
}

// just temporary

public func errorEquals(lhs: ErrorType, _ rhs: ErrorType) -> Bool {
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1 === error2
}

public let UnknownError  = NSError(domain: RxErrorDomain, code: RxErrorCode.Unknown.rawValue, userInfo: nil)
public let CastError     = NSError(domain: RxErrorDomain, code: RxErrorCode.Cast.rawValue, userInfo: nil)
public let DisposedError = NSError(domain: RxErrorDomain, code: RxErrorCode.Disposed.rawValue, userInfo: nil)

func removingObserverFailed() {
    rxFatalError("Removing observer for key failed")
}
