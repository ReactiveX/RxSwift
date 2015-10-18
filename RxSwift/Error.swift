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
*/
public enum RxErrorCode : Int {
    /**
    Unknown error occured
    */
    case Unknown   = 0
    /**
    Casting error
    */
    case Cast      = 2
    /**
    Performing an action on disposed object
    */
    case Disposed  = 3
    /**
    Aritmetic overflow error.
    */
    case Overflow  = 4
}

/**
Singleton instances of RxErrors
*/
public struct RxError {
    /**
    Singleton instance of unknown Error
    */
    public static let UnknownError  = NSError(domain: RxErrorDomain, code: RxErrorCode.Unknown.rawValue, userInfo: nil)

    /**
    Singleton instance of error during casting.
    */
    public static let CastError     = NSError(domain: RxErrorDomain, code: RxErrorCode.Cast.rawValue, userInfo: nil)

    /**
    Singleton instance of doing something on a disposed object error.
    */
    public static let DisposedError = NSError(domain: RxErrorDomain, code: RxErrorCode.Disposed.rawValue, userInfo: nil)

    /**
    Singleton instance of aritmetic overflow error.
    */
    public static let OverflowError = NSError(domain: RxErrorDomain, code: RxErrorCode.Overflow.rawValue, userInfo: nil)

}