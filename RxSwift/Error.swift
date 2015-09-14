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

/**
Generic Rx error codes.

- Unknown: Unknown error occured
- Cast: Error during Casting
- Disposed: Performing an action on disposed object
*/
public enum RxErrorCode : Int {
    case Unknown   = 0
    case Cast      = 2
    case Disposed  = 3
}

/**
Singleton instances of RxErrors
*/
public struct RxError {
    /**
    Singleton instance of Unknown Error
    */
    public static let UnknownError  = NSError(domain: RxErrorDomain, code: RxErrorCode.Unknown.rawValue, userInfo: nil)

    /**
    Singleton instance of error during casting
    */
    public static let CastError     = NSError(domain: RxErrorDomain, code: RxErrorCode.Cast.rawValue, userInfo: nil)

    /**
    Singleton instance of doing something on a disposed object
    */
    public static let DisposedError = NSError(domain: RxErrorDomain, code: RxErrorCode.Disposed.rawValue, userInfo: nil)

}