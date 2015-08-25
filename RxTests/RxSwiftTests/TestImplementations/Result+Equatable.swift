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
    case (.Success(let val1), .Success(let val2)):
        if let val1 = val1 as? Int, val2 = val2 as? Int {
            return val1 == val2
        }
        return false
    case (.Failure(let error1), .Failure(let error2)):
        return error1 as NSError === error2 as NSError
    default:
        return false
    }
}

