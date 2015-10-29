//
//  FailWith.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class FailWith<Element> : Producer<Element> {
    private let _error: ErrorType
    
    init(error: ErrorType) {
        _error = error
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        observer.on(.Error(_error))
        return NopDisposable.instance
    }
}