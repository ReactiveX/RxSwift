//
//  StableCompositeDisposable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 6/12/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public final class StableCompositeDisposable {
    public static func create(disposable1: Disposable, _ disposable2: Disposable) -> Disposable {
        return BinaryDisposable(disposable1, disposable2)
    }
    
    public static func create(disposable1: Disposable, _ disposable2: Disposable, _ disposable3: Disposable) -> Disposable {
        return TernaryDisposable(disposable1, disposable2, disposable3)
    }
    
    /*static func create(disposables: Disposable ...) -> Disposable {
        return NAryDisposable(disposables)
    }*/
}