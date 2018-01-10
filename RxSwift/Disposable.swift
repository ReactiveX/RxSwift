//
//  Disposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

public protocol DisposableConvertibleType {
    func asDisposable() -> Disposable
}

public protocol DisposableType: DisposableConvertibleType {
    func dispose()
}

/// Respresents a disposable resource.
public class Disposable: DisposableType {
    init() {
        #if TRACE_RESOURCES
            let _ = Resources.incrementTotal()
        #endif
    }

    deinit {
        #if TRACE_RESOURCES
            let _ = Resources.decrementTotal()
        #endif
    }

    /// Dispose resource.
    public func dispose() {

    }

    public func asDisposable() -> Disposable {
        return self
    }
}
