//
//  Observable+Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// debug

public func debug<E>(identifier: String)
    -> (Observable<E> -> Observable<E>) {
    return { source in
        return Debug(identifier: identifier, source: source)
    }
}