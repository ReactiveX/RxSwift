//
//  Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

#if TRACE_RESOURCES
/**
Counts internal Rx resources (Observables, Observers, Disposables ...).

It provides a really simple way to detect leaks early during development.
*/
public var resourceCount: Int32 = 0
#endif

// Swift doesn't have a concept of abstract metods.
// This function is being used as a runtime check that abstract methods aren't being called.
@noreturn func abstractMethod() -> Void {
    rxFatalError("Abstract method")
}

@noreturn func rxFatalError(lastMessage: String) {
    // The temptation to comment this line is great, but please don't, it's for your own good. The choice is yours.
    fatalError(lastMessage)
}

func incrementChecked(inout i: Int) throws -> Int {
    if i == Int.max {
        throw RxError.Overflow
    }
    let result = i
    i += 1
    return result
}

func decrementChecked(inout i: Int) throws -> Int {
    if i == Int.min {
        throw RxError.Overflow
    }
    let result = i
    i -= 1
    return result
}

extension NSObject {
    func rx_synchronized<T>(@noescape action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}
