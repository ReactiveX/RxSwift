//
//  NopDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Disposable that does nothing
// Nop = No Operation
public class NopDisposable : Disposable {
 
    public static let instance: Disposable = NopDisposable()
    
    init() {
        
    }
    
    public func dispose() {
    }
}