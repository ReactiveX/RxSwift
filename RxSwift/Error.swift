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
public enum RxError
    : ErrorType
    , CustomDebugStringConvertible {
    /**
    Unknown error occured.
    */
    case Unknown
    /**
    Performing an action on disposed object.
    */
    case Disposed(object: AnyObject)
    /**
    Aritmetic overflow error.
    */
    case Overflow
    /**
    Argument out of range error.
    */
    case ArgumentOutOfRange
    /**
    No elements sent to a sequence requiring at least one.
    */
    case NoElements
    /**
    More elements sent to a sequence expecting only one.
    */
    case MoreThanOneElement
}

public extension RxError {
    /**
     A textual representation of `self`, suitable for debugging.
    */
    public var debugDescription: String {
        switch self {
        case .Unknown:
            return "Unknown error occured"
        case .Disposed(let object):
            return "Object `\(object)` was already disposed"
        case .Overflow:
            return "Arithmetic overflow occured"
        case .ArgumentOutOfRange:
            return "Argument out of range"
        case .NoElements:
            return "No element sent to a sequence requiring at least one"
        case .MoreThanOneElement:
            return "More elements sent to a sequence expecting only one"
        }
    }
}