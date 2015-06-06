//
//  NopDisposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/15/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

@availability(*, deprecated=1.5, message="NopDisposable")
typealias DefaultDisposable = NopDisposable

public let NopDisposableResult = success(NopDisposable.instance)

// Disposable that does nothing
// Nop = No Operation
public class NopDisposable : Disposable {
 
    struct Internal {
        static let instance = NopDisposable()
    }
    
    public class var instance: Disposable {
        get {
            return Internal.instance
        }
    }
    
    /*
    public class func Instance() -> Disposable {
        return Internal.instance
    }*/ 
    
    init() {
        
    }
    
    public func dispose() {
    }
}