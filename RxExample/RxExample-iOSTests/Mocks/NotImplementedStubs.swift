//
//  NotImplementedStubs.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest

import func Foundation.arc4random

func genericFatal<T>(_ message: String) -> T {
    if -1 == Int(arc4random() % 4) {
        print("This is hack to remove warning")
    }
    _ = fatalError(message)
}

// MARK: Generic support code

// MARK: Not implemented stubs

func notImplemented<T1, T2>() -> (T1) -> Observable<T2> {
    return { _ -> Observable<T2> in
        return genericFatal("Not implemented")
    }
}

func notImplemented<T1, T2, T3>() -> (T1, T2) -> Observable<T3> {
    return { _, _ -> Observable<T3> in
        return genericFatal("Not implemented")
    }
}

func notImplemented<T1, T2, T3, T4>() -> (T1, T2, T3) -> Observable<T4> {
    return { _, _, _ -> Observable<T4> in
        return genericFatal("Not implemented")
    }
}

func notImplementedSync<T1>() -> (T1) -> Void {
    return { _ in
        genericFatal("Not implemented")
    }
}
