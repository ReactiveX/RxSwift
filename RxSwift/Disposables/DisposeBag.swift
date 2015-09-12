//
//  DisposeBag.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/25/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

extension Disposable {
    /**
    Adds `self` to `bag`.
    
    - parameter bag: `DisposeBag` to add `self` to.
    */
    public func addDisposableTo(bag: DisposeBag) {
        bag.addDisposable(self)
    }
}

/**
Thread safe bag that disposes added disposables on `deinit`.

This returns ARC (RAII) like resource management to `RxSwift`.

In case contained disposables need to be disposed, just deference dispose bag
or create new one in it's place.

    self.existingDisposeBag = DisposeBag()

In case explicit disposal is necessary, there is also `CompositeDisposable`.
*/
public class DisposeBag: DisposeBase {
    
    private let lock = SpinLock()
    private var disposables = [Disposable]()
    
    /**
    Adds `disposable` to be disposed when dispose bag is being deinited.
    
    - parameter disposable: Disposable to add.
    */
    public func addDisposable(disposable: Disposable) {
        lock.performLocked {
            disposables.append(disposable)
        }
    }
    
    deinit {
        disposables.forEach {
            $0.dispose()
        }
    }
}