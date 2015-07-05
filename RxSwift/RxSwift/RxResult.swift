//
//  RxResult.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Represents computation result.
//
// The result can be either successful or failure.
//
// It's a port of Scala (originally Twitter) `Try` type
// http://www.scala-lang.org/api/2.10.2/index.html#scala.util.Try
// The name `Result` was chosen because it better describes it's common usage.
//
// The reason why it's named differently is because `Try` doesn't make sense in the context
// of swift.
//
// In scala it would be used like `Try { throw new Exception("oh dear") }`
//
// The reason why `Result` has `Rx` prefix is because there could be name collisions with other
// result types.
//
public enum RxResult<T> {
    // Box is used is because swift compiler doesn't know
    // how to handle `Success(ResultType)` and it crashes.
    case Success(RxBox<T>)
    case Failure(ErrorType)
}

extension RxResult {
    
    // Returns true if `self` is a `Success`, false otherwise.
    public var isSuccess: Bool {
        get {
            switch self {
            case .Success:
                return true
            default:
                return false
            }
        }
    }

    // Returns true if `self` is a `Failure`, false otherwise.
    public var isFailure: Bool {
        get {
            switch self {
            case .Failure:
                return true
            default:
                return false
            }
        }
    }
    
    // Returns the given function applied to the value from `Success` or returns `self` if this is a `Failure`.
    public func flatMap<U>(@noescape f: T -> RxResult<U>) -> RxResult<U> {
        switch self {
        case .Success(let boxedValue):
            return f(boxedValue.value)
        case .Failure(let error):
            return failure(error)
        }
    }
    
    // Maps the given function to the value from `Success` or returns `self` if this is a `Failure`.
    public func map<U>(@noescape f: T -> U) -> RxResult<U> {
        switch self {
        case .Success(let boxedValue):
            return success(f(boxedValue.value))
        case .Failure(let error):
            return failure(error)
        }
    }
    
    // Applies the given function `f` if this is a `Failure`, otherwise returns `self` if this is a `Success`.
    public func recover(@noescape f: (ErrorType) -> T) -> RxResult<T> {
        switch self {
        case .Success(_):
            return self
        case .Failure(let error):
            return success(f(error))
        }
    }
    
    // Applies the given function `f` if this is a `Failure`, otherwise returns `self` if this is a `Success`.
    public func recoverWith(@noescape f: (ErrorType) -> RxResult<T>) -> RxResult<T> {
        switch self {
        case .Success(_):
            return self
        case .Failure(let error):
            return f(error)
        }
    }
    
    // Returns the value if `Success` or throws the exception if this is a Failure.
    public func get() -> T {
        switch self {
        case .Success(let boxedValue):
            return boxedValue.value
        case .Failure(let error):
            rxFatalError("Result represents failure: \(error)")
            return (nil as T?)!
        }
    }
    
    // Returns the value if `Success` or the given `defaultValue` if this is a `Failure`.
    public func getOrElse(defaultValue: T) -> T {
        switch self {
        case .Success(let boxedValue):
            return boxedValue.value
        case .Failure(_):
            return defaultValue
        }
    }
    
    // Returns `self` if `Success` or the given `defaultValue` if this is a `Failure`.
    public func getOrElse(defaultValue: RxResult<T>) -> RxResult<T> {
        switch self {
        case .Success(_):
            return self
        case .Failure(_):
            return defaultValue
        }
    }

    // Returns `nil` if this is a `Failure` or a `T` containing the value if this is a `Success`
    public func toOptional() -> T? {
        switch self {
        case .Success(let boxedValue):
            return boxedValue.value
        case .Failure(_):
            return nil
        }
    }
}

// convenience constructor

public func success<T>(value: T) -> RxResult<T> {
    return .Success(RxBox(value))
}

public func failure<T>(error: ErrorType) -> RxResult<T> {
    return .Failure(error)
}

public let SuccessResult = success(())

// lift functions

// "Lifts" functions that take normal arguments to functions that take `Result` monad arguments.
// Unfortunately these are not generic `Monad` lift functions because
// Creating generic lift functions that work for arbitrary monads is a lot more tricky.

func lift<T1, TRet>(function: (T1) -> TRet) -> (RxResult<T1>) -> RxResult<TRet> {
    return { arg1 in
        return arg1.map { value1 in
            return function(value1)
        }
    }
}

func lift<T1, T2, TRet>(function: (T1, T2) -> TRet) -> (RxResult<T1>, RxResult<T2>) -> RxResult<TRet> {
    return { arg1, arg2 in
        return arg1.flatMap { value1 in
            return arg2.map { value2 in
                return function(value1, value2)
            }
        }
    }
}

func lift<T1, T2, T3, TRet>(function: (T1, T2, T3) -> TRet) -> (RxResult<T1>, RxResult<T2>, RxResult<T3>) -> RxResult<TRet> {
    return { arg1, arg2, arg3 in
        return arg1.flatMap { value1 in
            return arg2.flatMap { value2 in
                return arg3.map { value3 in
                    return function(value1, value2, value3)
                }
            }
        }
    }
}

// depricated

@availability(*, deprecated=1.4, message="Replaced by success")
public func `return`<T>(value: T) -> RxResult<T> {
    return .Success(RxBox(value))
}

infix operator >== { associativity left precedence 95 }

@availability(*, deprecated=1.4, message="Replaced by flatMap")
public func >== <In, Out>(lhs: RxResult<In>, @noescape rhs: (In) -> RxResult<Out>) -> RxResult<Out> {
    switch lhs {
    case .Success(let result): return rhs(result.value)
    case .Failure(let error): return .Failure(error)
    }
}

@availability(*, deprecated=1.4, message="Replaced by map")
public func >== <In, Out>(lhs: RxResult<In>, @noescape rhs: (In) -> Out) -> RxResult<Out> {
    switch lhs {
    case .Success(let result): return success(rhs(result.value))
    case .Failure(let error): return .Failure(error)
    }
}

infix operator >>> { associativity left precedence 95 }

@availability(*, deprecated=1.4, message="Replaced by map")
public func >>> <In, Out>(lhs: RxResult<In>, @noescape rhs: () -> Out) -> RxResult<Out> {
    switch lhs {
    case .Success: return success(rhs())
    case .Failure(let error): return .Failure(error)
    }
}

@availability(*, deprecated=1.4, message="Replaced by flatMap")
public func >>> <In, Out>(lhs: RxResult<In>, @noescape rhs: () -> RxResult<Out>) -> RxResult<Out> {
    switch lhs {
    case .Success: return rhs()
    case .Failure(let error): return .Failure(error)
    }
}

infix operator >>! { associativity left precedence 95 }

@availability(*, deprecated=1.4, message="Replaced by recoverWith")
public func >>! <In>(lhs: RxResult<In>, @noescape rhs: (ErrorType) -> RxResult<In>) -> RxResult<In> {
    switch lhs {
    case .Failure(let error):
        return rhs(error)
    default:
        return lhs
    }
}

prefix operator * { }

@availability(*, deprecated=1.4, message="Replaced by get")
public prefix func *<T>(result: RxResult<T>) -> T {
    switch result {
    case .Success(let value): return value.value
    default:
        var result: T? = nil
        return result!
    }
}

@availability(*, deprecated=1.4, message="Replaced by recover")
public func replaceErrorWith<T>(result: RxResult<T>, errorValue: T) -> T {
    switch result {
    case .Success(let boxedValue):
        return boxedValue.value
    case .Failure:
        return errorValue
    }
}

@availability(*, deprecated=1.4, message="Replaced by recoverWith")
public func replaceErrorWithNil<T>(result: RxResult<T>) -> T? {
    switch result {
    case .Success(let boxedValue):
        return boxedValue.value
    case .Failure:
        return nil
    }
}

