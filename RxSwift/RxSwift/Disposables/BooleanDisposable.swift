//
//  CancelDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 7/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class BooleanDisposable : Cancelable {
    private var _disposed: Bool = false
    public var disposed: Bool {
        get {
            return _disposed
        }
    }
    
    public init() {
        
    }
    
    public func dispose()  {
        _disposed = true
    }
}