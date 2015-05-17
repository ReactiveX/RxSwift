//
//  Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if TRACE_RESOURCES
// counts resources
// used to detect resource leaks during unit tests
// it's not perfect, but works well
public var resourceCount: Int32 = 0
#endif

// This is the pipe operator (left associative function application operator)
//      a >- b >- c  ==   c(b(a))
// The reason this one is chosen for now is because
//  * It's subtle, doesn't add a lot of visual noise
//  * It's short
//  * It kind of looks like ASCII art horizontal sink to the right
//
infix operator >- { associativity left precedence 91 }

public func >- <In, Out>(lhs: In, @noescape rhs: In -> Out) -> Out {
    return rhs(lhs)
}

func contract(@autoclosure  condition: () -> Bool) {
    if !condition() {
        let exception = NSException(name: "ContractError", reason: "Contract failed", userInfo: nil)
        exception.raise()
    }
}

// Because ... Swift
// Because ... Crash
// Because ... compiler bugs

// Wrapper for any value type
public class Box<T> : Printable {
    public let value : T
    public init (_ value: T) {
        self.value = value
    }
    
    public var description: String {
        get {
            return "Box(\(self.value))"
        }
    }
}

// Wrapper for any value type that can be mutated
public class MutatingBox<T> : Printable {
    public var value : T
    public init (_ value: T) {
        self.value = value
    }
    
    public var description: String {
        get {
            return "MutatingBox(\(self.value))"
        }
    }
}

// Swift doesn't have a concept of abstract metods.
// This function is being used as a runtime check that abstract methods aren't being called.
func abstractMethod<T>() -> T {
    rxFatalError("Abstract method")
    let dummyValue: T? = nil
    return dummyValue!
}

func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}
