//
//  RxResult+Equatable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension RxResult : Equatable {
    
}

public func == <E>(lhs: RxResult<E>, rhs: RxResult<E>) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let boxed1), .Success(let boxed2)):
        var val1 = boxed1.value
        var val2 = boxed2.value
        return memcmp(&val1, &val2, sizeof(E)) == 0
    case (.Failure(let error1), .Failure(let error2)):
        return error1 === error2
    default:
        return false
    }
}

