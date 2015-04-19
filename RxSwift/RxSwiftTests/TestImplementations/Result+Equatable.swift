//
//  Result+Equatable.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 4/20/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

extension Result : Equatable {
    
}

public func == <E>(lhs: Result<E>, rhs: Result<E>) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let boxed1), .Success(let boxed2)):
        var val1 = boxed1.value
        var val2 = boxed2.value
        return memcmp(&val1, &val2, sizeof(E)) == 0
    case (.Error(let error1), .Error(let error2)):
        return error1 === error2
    default:
        return false
    }
}

