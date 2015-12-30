//
//  NotImplementedStubs.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTests

// MARK: Generic support code


// MARK: Not implemented stubs

func notImplemented<T1, T2>() -> (T1) -> Observable<T2> {
    return { _ in
        fatalError()
        return Observable.empty()
    }
}

func notImplementedSync<T1>() -> (T1) -> Void {
    return { _ in
        fatalError()
    }
}
