//
//  DisposeBase.swift
//  Rx
//
//  Created by Krunoslav Zaher on 4/4/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class DisposeBase {
    init() {
#if DEBUG
    OSAtomicIncrement32(&resourceCount)
#endif
    }
    
    deinit {
#if DEBUG
    OSAtomicDecrement32(&resourceCount)
#endif
    }
}