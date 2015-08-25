//
//  Observable+Debug.swift
//  RxSwift
//
//  Created by Krunoslav Zaher on 5/2/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// debug

extension ObservableType {
    public func debug(identifier: String = "\(__FILE__):\(__LINE__)")
        -> Observable<E> {
        return Debug(source: self.asObservable(), identifier: identifier)
    }
}