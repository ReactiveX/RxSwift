//
//  Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/14/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public func justUseIt<T>(_: T) {
    
}

#if TRACE_RESOURCES
// counts resources
// used to detect resource leaks during unit tests
// it's not perfect, but works well
public var resourceCount: Int32 = 0
public var numberOfSerialDispatchQueueObservables: Int32 = 0
#endif

func contract(@autoclosure  condition: () -> Bool) {
    if !condition() {
        let exception = NSException(name: "ContractError", reason: "Contract failed", userInfo: nil)
        exception.raise()
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

extension NSObject {
    func rx_synchronized<T>(@noescape action: () -> T) -> T {
        objc_sync_enter(self)
        let result = action()
        objc_sync_exit(self)
        return result
    }
}
