//
//  AnyObject+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public func castOrFail<T>(result: AnyObject!) -> Result<T> {
    if let typedResult = result as? T {
        return success(typedResult)
    }
    else {
        return .Error(CastError)
    }
}

public func makeOptionalResult<T>(result: T) -> Result<T?> {
    return success(result)
}

public func makeOptional<T>(result: T) -> T? {
    return result
}

