//
//  Disposable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/8/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol Disposable
{
    func dispose()
}

public func allSucceedOrDispose(disposables: [Result<Disposable>]) -> Result<Disposable> {
    let errors = disposables.filter { d in d.error != nil }
    let numberOfFailures = errors.count
    if numberOfFailures == 0 {
        return success(CompositeDisposable(disposables: disposables.map { d in d.value!}))
    }
    else {
        // dispose all of the resources
        let diposeResult: [Void] = disposables.map { d  in
            switch d {
            case .Success(let disposable):
                disposable.value.dispose()
                break;
            case .Error(let error): break
            }
            
            return ()
        }
        return createCompositeFailure(errors)
    }
}