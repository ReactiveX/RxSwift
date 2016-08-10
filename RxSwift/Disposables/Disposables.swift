//
//  Disposables.swift
//  Rx
//
//  Created by Mohsen Ramezanpoor on 01/08/2016.
//  Copyright © 2016 Mohsen Ramezanpoor. All rights reserved.
//

import Foundation

public struct Disposables {
    
}

public extension Disposables {
    
    private static let noOp: Disposable = NopDisposable()
    
    static func create() -> Disposable {
        return noOp
    }
    
    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) -> Cancelable {
        return CompositeDisposable(disposable1, disposable2, disposable3)
    }
    
    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposables: Disposable ...) -> Cancelable {
        var disposables = disposables
        disposables.append(disposable1)
        disposables.append(disposable2)
        disposables.append(disposable3)
        return CompositeDisposable(disposables: disposables)
    }
    
    static func create(_ disposables: [Disposable]) -> Cancelable {
        switch disposables.count {
        case 2:
            return Disposables.create(disposables[0], disposables[1])
        default:
            return CompositeDisposable(disposables: disposables)
        }
    }
    
}
