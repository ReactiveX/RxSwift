//
//  RxCocoa.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
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
    Error during swizzling.
    */
    case ErrorDuringSwizzling
    /*
     Casting error.
     */
    case CastingError(object: AnyObject, targetType: Any.Type)
}

#if !DISABLE_SWIZZLING
/**
RxCocoa ObjC runtime interception mechanism.
 */
public enum RxCocoaInterceptionMechanism {
    /**
     Unknown message interception mechanism.
    */
    case Unknown
    /**
     Key value observing interception mechanism.
    */
    case KVO
}

/**
RxCocoa ObjC runtime modification errors.
 */
public enum RxCocoaObjCRuntimeError
    : ErrorType
    , CustomDebugStringConvertible {
    /**
    Unknown error has occurred.
    */
    case Unknown(target: AnyObject)

    /**
    If the object is reporting a different class then it's real class, that means that there is probably
    already some interception mechanism in place or something weird is happening.

    The most common case when this would happen is when using a combination of KVO (`rx_observe`) and `rx_sentMessage`.

    This error is easily resolved by just using `rx_sentMessage` observing before `rx_observe`.

    The reason why the other way around could create issues is because KVO will unregister it's interceptor
    class and restore original class. Unfortunately that will happen no matter was there another interceptor
    subclass registered in hierarchy or not.

    Failure scenario:
    * KVO sets class to be `__KVO__OriginalClass` (subclass of `OriginalClass`)
    * `rx_sentMessage` sets object class to be `_RX_namespace___KVO__OriginalClass` (subclass of `__KVO__OriginalClass`)
    * then unobserving with KVO will restore class to be `OriginalClass` -> failure point (possibly a bug in KVO)

    The reason why changing order of observing works is because any interception method on unregistration 
    should return object's original real class (if that doesn't happen then it's really easy to argue that's a bug
    in that interception mechanism).

    This library won't remove registered interceptor even if there aren't any observers left because
    it's highly unlikely it would have any benefit in real world use cases, and it's even more
    dangerous.
    */
    case ObjectMessagesAlreadyBeingIntercepted(target: AnyObject, interceptionMechanism: RxCocoaInterceptionMechanism)

    /**
    Trying to observe messages for selector that isn't implemented.
    */
    case SelectorNotImplemented(target: AnyObject)

    /**
    Core Foundation classes are usually toll free bridged. Those classes crash the program in case
    `object_setClass` is performed on them.

    There is a possibility to just swizzle methods on original object, but since those won't be usual use
    cases for this library, then an error will just be reported for now.
    */
    case CantInterceptCoreFoundationTollFreeBridgedObjects(target: AnyObject)

    /**
    Two libraries have simultaneously tried to modify ObjC runtime and that was detected. This can only
    happen in scenarios where multiple interception libraries are used.
     
    To synchronize other libraries intercepting messages for an object, use `synchronized` on target object and
    it's meta-class.
    */
    case ThreadingCollisionWithOtherInterceptionMechanism(target: AnyObject)

    /**
    For some reason saving original method implementation under RX namespace failed.
    */
    case SavingOriginalForwardingMethodFailed(target: AnyObject)

    /**
    Intercepting a sent message by replacing a method implementation with `_objc_msgForward` failed for some reason.
    */
    case ReplacingMethodWithForwardingImplementation(target: AnyObject)

    /**
    Attempt to intercept one of the performance sensitive methods:
        * class
        * respondsToSelector:
        * methodSignatureForSelector:
        * forwardingTargetForSelector:
    */
    case ObservingPerformanceSensitiveMessages(target: AnyObject)

    /**
    Message implementation has unsupported return type (for example large struct). The reason why this is a error
    is because in some cases intercepting sent messages requires replacing implementation with `_objc_msgForward_stret` 
    instead of `_objc_msgForward`.

    The unsupported cases should be fairly uncommon.
    */
    case ObservingMessagesWithUnsupportedReturnType(target: AnyObject)
}

#endif

// MARK: Debug descriptions

public extension RxCocoaError {
    /**
     A textual representation of `self`, suitable for debugging.
     */
    public var debugDescription: String {
        switch self {
        case .Unknown:
            return "Unknown error occurred."
        case let .InvalidOperation(object):
            return "Invalid operation was attempted on `\(object)`."
        case let .ItemsNotYetBound(object):
            return "Data source is set, but items are not yet bound to user interface for `\(object)`."
        case let .InvalidPropertyName(object, propertyName):
            return "Object `\(object)` dosn't have a property named `\(propertyName)`."
        case let .InvalidObjectOnKeyPath(object, sourceObject, propertyName):
            return "Unobservable object `\(object)` was observed as `\(propertyName)` of `\(sourceObject)`."
        case .ErrorDuringSwizzling:
            return "Error during swizzling."
        case .CastingError(let object, let targetType):
            return "Error casting `\(object)` to `\(targetType)`"
        }
    }
}

#if !DISABLE_SWIZZLING

public extension RxCocoaObjCRuntimeError {
    /**
     A textual representation of `self`, suitable for debugging.
     */
    public var debugDescription: String {
        switch self {
        case let .Unknown(target):
            return "Unknown error occurred.\nTarget: `\(target)`"
        case let ObjectMessagesAlreadyBeingIntercepted(target, interceptionMechanism):
            let interceptionMechanismDescription = interceptionMechanism == .KVO ? "KVO" : "other interception mechanism"
            return "Collision between RxCocoa interception mechanism and \(interceptionMechanismDescription)."
            + " To resolve this conflict please use this interception mechanism first.\nTarget: \(target)"
        case let SelectorNotImplemented(target):
            return "Trying to observe messages for selector that isn't implemented.\nTarget: \(target)"
        case let CantInterceptCoreFoundationTollFreeBridgedObjects(target):
            return "Interception of messages sent to Core Foundation isn't supported.\nTarget: \(target)"
        case let ThreadingCollisionWithOtherInterceptionMechanism(target):
            return "Detected a conflict while modifying ObjC runtime.\nTarget: \(target)"
        case let SavingOriginalForwardingMethodFailed(target):
            return "Saving original method implementation failed.\nTarget: \(target)"
        case let ReplacingMethodWithForwardingImplementation(target):
            return "Intercepting a sent message by replacing a method implementation with `_objc_msgForward` failed for some reason.\nTarget: \(target)"
        case let ObservingPerformanceSensitiveMessages(target):
            return "Attempt to intercept one of the performance sensitive methods. \nTarget: \(target)"
        case let ObservingMessagesWithUnsupportedReturnType(target):
            return "Attempt to intercept a method with unsupported return type. \nTarget: \(target)"
        }
    }
}

#endif

// MARK: Error binding policies

func bindingErrorToInterface(error: ErrorType) {
    let error = "Binding error to UI: \(error)"
#if DEBUG
    rxFatalError(error)
#else
    print(error)
#endif
}

// MARK: Abstract methods

@noreturn func rxAbstractMethodWithMessage(message: String) {
    rxFatalError(message)
}

@noreturn func rxAbstractMethod() {
    rxFatalError("Abstract method")
}

// MARK: casts or fatal error

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

func castOrFatalError<T>(value: Any!) -> T {
    let maybeResult: T? = value as? T
    guard let result = maybeResult else {
        rxFatalError("Failure converting from \(value) to \(T.self)")
    }
    
    return result
}

// MARK: Error messages

let dataSourceNotSet = "DataSource not set"
let delegateNotSet = "Delegate not set"

#if !DISABLE_SWIZZLING

// MARK: Conversions `NSError` > `RxCocoaObjCRuntimeError`

extension NSError {
    func rxCocoaErrorForTarget(target: AnyObject) -> RxCocoaObjCRuntimeError {
        if domain == RXObjCRuntimeErrorDomain {
            let errorCode = RXObjCRuntimeError(rawValue: self.code) ?? .Unknown

            switch errorCode {
            case .Unknown:
                return .Unknown(target: target)
            case .ObjectMessagesAlreadyBeingIntercepted:
                let isKVO = (self.userInfo[RXObjCRuntimeErrorIsKVOKey] as? NSNumber)?.boolValue ?? false
                return .ObjectMessagesAlreadyBeingIntercepted(target: target, interceptionMechanism: isKVO ? .KVO : .Unknown)
            case .SelectorNotImplemented:
                return .SelectorNotImplemented(target: target)
            case .CantInterceptCoreFoundationTollFreeBridgedObjects:
                return .CantInterceptCoreFoundationTollFreeBridgedObjects(target: target)
            case .ThreadingCollisionWithOtherInterceptionMechanism:
                return .ThreadingCollisionWithOtherInterceptionMechanism(target: target)
            case .SavingOriginalForwardingMethodFailed:
                return .SavingOriginalForwardingMethodFailed(target: target)
            case .ReplacingMethodWithForwardingImplementation:
                return .ReplacingMethodWithForwardingImplementation(target: target)
            case .ObservingPerformanceSensitiveMessages:
                return .ObservingPerformanceSensitiveMessages(target: target)
            case .ObservingMessagesWithUnsupportedReturnType:
                return .ObservingMessagesWithUnsupportedReturnType(target: target)
            }
        }

        return RxCocoaObjCRuntimeError.Unknown(target: target)
    }
}

#endif


// MARK: Shared with RxSwift

#if !RX_NO_MODULE

@noreturn func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

#endif
