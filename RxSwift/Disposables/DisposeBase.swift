//
//  DisposeBase.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

/// Base class for all disposables.
public class DisposeBase {
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
}
