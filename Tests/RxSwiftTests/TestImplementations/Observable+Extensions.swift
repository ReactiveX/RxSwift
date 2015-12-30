//
//  Observable+Extensions.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import RxTests

public func == <T>(lhs: Observable<T>, rhs: Observable<T>) -> Bool {
    return lhs === rhs
}

extension TestableObservable : Equatable {

}

public func == <T>(lhs: TestableObservable<T>, rhs: TestableObservable<T>) -> Bool {
    return lhs === rhs
}

