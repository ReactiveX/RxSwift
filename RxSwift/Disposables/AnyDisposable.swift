//
//  AnyDisposable.swift
//  RxSwift
//
//  Created by tarunon on 2018/01/10.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

internal class AnyDisposable<D: DisposableType>: Disposable {
    let disposable: D
    init(_ disposable: D) {
        self.disposable = disposable
    }

    override func dispose() {
        disposable.dispose()
    }
}

public extension DisposableType {
    func asDisposable() -> Disposable {
        return AnyDisposable(self)
    }
}
