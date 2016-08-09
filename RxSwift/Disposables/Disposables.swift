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
    
    static func empty() -> Disposable {
        return NopDisposable.instance
    }
    
    static func create(with action: () -> ()) -> Disposable {
        return AnonymousDisposable(action)
    }
    
    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) -> Disposable {
        return CompositeDisposable(disposable1, disposable2, disposable3)
    }
    
    static func create(_ disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable, _ disposable4: Disposable) -> Disposable {
        return CompositeDisposable(disposable1, disposable2, disposable3, disposable4)
    }
    
    static func create(_ disposables: [Disposable]) -> Disposable {
        switch disposables.count {
        case 0:
            return Disposables.empty()
        case 1:
            return disposables[0]
        case 2:
            return Disposables.create(disposables[0], disposables[1])
        default:
            return CompositeDisposable(disposables: disposables)
        }
    }
    
}
