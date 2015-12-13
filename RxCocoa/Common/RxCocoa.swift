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

/**
RxCocoa errors.
*/
public enum RxCocoaError
    : ErrorType
    , CustomDebugStringConvertible {
    /**
    Unknown error has occurred.
    */
    case Unknown
    /**
    Invalid operation was attempted.
    */
    case InvalidOperation(object: AnyObject)
    /**
    Items are not yet bound to user interface but have been requested.
    */
    case ItemsNotYetBound(object: AnyObject)
    /**
    Invalid KVO Path.
    */
    case InvalidPropertyName(object: AnyObject, propertyName: String)
    /**
    Invalid object on key path.
    */
    case InvalidObjectOnKeyPath(object: AnyObject, sourceObject: AnyObject, propertyName: String)
    /**
     Casting error.
     */
    case CastingError(object: AnyObject, targetType: Any.Type)
}

public extension RxCocoaError {
    /**
     A textual representation of `self`, suitable for debugging.
     */
    public var debugDescription: String {
        switch self {
        case .Unknown:
            return "Unknown error occurred"
        case let .InvalidOperation(object):
            return "Invalid operation was attempted on `\(object)`"
        case let .ItemsNotYetBound(object):
            return "Data source is set, but items are not yet bound to user interface for `\(object)`"
        case let .InvalidPropertyName(object, propertyName):
            return "Object `\(object)` dosn't have a property named `\(propertyName)`"
        case let .InvalidObjectOnKeyPath(object, sourceObject, propertyName):
            return "Unobservable object `\(object)` was observed as `\(propertyName)` of `\(sourceObject)`"
        case .CastingError(let object, let targetType):
            return "Error casting `\(object)` to `\(targetType)`"
        }
    }
}

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
#if DEBUG
    rxFatalError(error)
#else
    print(error)
#endif
}

func bindingErrorToVariable(error: ErrorType) {
    let error = "Binding error to variable: \(error)"
#if DEBUG
    rxFatalError(error)
#else
    print(error)
#endif
}

@noreturn func rxAbstractMethodWithMessage(message: String) {
    rxFatalError(message)
}

@noreturn func rxAbstractMethod() {
    rxFatalError("Abstract method")
}

// workaround for Swift compiler bug, cheers compiler team :)
func castOptionalOrFatalError<T>(value: AnyObject?) -> T? {
    if value == nil {
        return nil
    }
    let v: T = castOrFatalError(value)
    return v
}

func castOrThrow<T>(resultType: T.Type, _ object: AnyObject) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.CastingError(object: object, targetType: resultType)
    }

    return returnValue
}

func castOptionalOrThrow<T>(resultType: T.Type, _ object: AnyObject) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }

    guard let returnValue = object as? T else {
        throw RxCocoaError.CastingError(object: object, targetType: resultType)
    }

    return returnValue
}

func castOrFatalError<T>(value: AnyObject!, message: String) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError(message)
    }
    
    return result
}

func castOrFatalError<T>(value: AnyObject!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

// Error messages {

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

// }


#if !RX_NO_MODULE

@noreturn func rxFatalError(lastMessage: String) {
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

#endif
