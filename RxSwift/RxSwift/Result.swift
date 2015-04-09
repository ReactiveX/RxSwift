//
//  Result.swift
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
// Result is a `Either` Haskell monad.
// The name `Result` was chosen because it better describes it's common usage.
//
public enum Result<ResultType> {
    // Box is used is because swift compiler doesn't know
    // how to handle `Success(ResultType)` and it crashes.
    case Success(Box<ResultType>)
    case Error(ErrorType)
    
    init(_ value: ResultType) {
        self = .Success(Box(value))
    }
    
    init(_ error: ErrorType) {
        self = .Error(error)
    }
    
    public var error: ErrorType? {
        get {
            switch self {
            case .Error(let error): return error
            default: return nil
            }
        }
    }
    
    public var value : ResultType? {
        get {
            switch self {
            case .Success(let value): return value.value
            default: return nil
            }
        }
    }
}

public let SuccessResult = success(())

// Monad implementation for Result

// Monadic `return` implementation
// 
// Naming clash with `return` keyword, `Success` function is more practical replacement.
public func `return`<T>(value: T) -> Result<T> {
    return .Success(Box(value))
}

// Monadic `bind` implementation
// 
// `>==` is being used because `>>=` is already reserved operator in Swift.
infix operator >== { associativity left precedence 95 }

public func >== <In, Out>(lhs: Result<In>, @noescape rhs: (In) -> Result<Out>) -> Result<Out> {
    switch lhs {
    case .Success(let result): return rhs(result.value)
    case .Error(let error): return .Error(error)
    }
}

public func >== <In, Out>(lhs: Result<In>, @noescape rhs: (In) -> Out) -> Result<Out> {
    switch lhs {
    case .Success(let result): return success(rhs(result.value))
    case .Error(let error): return .Error(error)
    }
}

// Control flow operators for `Result`

// In case `lhs` succeeded, result equals `rhs()`
// In case `lhs` failed, just propagates failure
infix operator >>> { associativity left precedence 95 }

public func >>> <In, Out>(lhs: Result<In>, @noescape rhs: () -> Out) -> Result<Out> {
    switch lhs {
    case .Success: return success(rhs())
    case .Error(let error): return .Error(error)
    }
}

public func >>> <In, Out>(lhs: Result<In>, @noescape rhs: () -> Result<Out>) -> Result<Out> {
    switch lhs {
    case .Success: return rhs()
    case .Error(let error): return .Error(error)
    }
}

// catch / fail operator
//
// In case `lhs` succeeded, result is propagated
// In case `lhs` failed, result is equal to `rhs(error)` (catch clause) result
infix operator >>! { associativity left precedence 95 }

public func >>! <In>(lhs: Result<In>, @noescape rhs: (ErrorType) -> Result<In>) -> Result<In> {
    switch lhs {
    case .Error(let error):
        return rhs(error)
    default:
        return lhs
    }
}

// This shouldn't be a common operator to use (although it does come in handy sometime)
//
// In case `Result` contains value it will return value, otherwise it will throw an exception
// This should only be used when the result is already checked for failure
//
// `>==` operator or lift functions are preferred.
//
prefix operator * { }
public prefix func *<T>(result: Result<T>) -> T {
    switch result {
    case .Success(let value): return value.value
    default:
        var result: T? = nil
        return result!
    }
}

// Convenience constructor
public func success<T>(value: T) -> Result<T> {
    return .Success(Box(value))
}

// aggregate `Result` functions

public func doAll(results: [Result<Void>]) -> Result<Void> {
    var failures = results.filter { $0.error != nil }
    if failures.count > 0 {
        return createCompositeFailure(failures)
    }
    else {
        return SuccessResult
    }
}


// lift functions

// "Lifts" functions that take normal arguments to functions that take `Result` monad arguments.
// Unfortunatelly these are not generic `Monad` lift functions because
// creating generic lift functions that work for arbitrary monads is a lot more tricky.

func lift<T1, TRet>(function: (T1) -> TRet) -> (Result<T1>) -> Result<TRet> {
    return { arg1 in
        return arg1 >== { value1 in
            return success(function(value1))
        }
    }
}

func lift<T1, T2, TRet>(function: (T1, T2) -> TRet) -> (Result<T1>, Result<T2>) -> Result<TRet> {
    return { arg1, arg2 in
        return arg1 >== { value1 in
            return arg2 >== { value2 in
                return success(function(value1, value2))
            }
        }
    }
}

func lift<T1, T2, T3, TRet>(function: (T1, T2, T3) -> TRet) -> (Result<T1>, Result<T2>, Result<T3>) -> Result<TRet> {
    return { arg1, arg2, arg3 in
        return arg1 >== { value1 in
            return arg2 >== { value2 in
                return arg3 >== { value3 in
                    return success(function(value1, value2, value3))
                }
            }
        }
    }
}

// error conversion functions

public func replaceErrorWith<T>(result: Result<T>, errorValue: T) -> T {
    switch result {
    case .Success(let boxedValue):
        return boxedValue.value
    case .Error:
        return errorValue
    }
}

public func replaceErrorWithNil<T>(result: Result<T>) -> T? {
    switch result {
    case .Success(let boxedValue):
        return boxedValue.value
    case .Error:
        return nil
    }
}