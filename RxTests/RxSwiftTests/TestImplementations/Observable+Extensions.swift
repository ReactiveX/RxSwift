//
//  Observable+Extensions.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//
//

import Foundation
import RxSwift

public func == <T>(lhs: Observable<T>, rhs: Observable<T>) -> Bool {
    return lhs === rhs
}

extension HotObservable : Equatable {

}

extension ColdObservable : Equatable {
    
}

func == <T>(lhs: HotObservable<T>, rhs: HotObservable<T>) -> Bool {
    return lhs === rhs
}

func == <T>(lhs: ColdObservable<T>, rhs: ColdObservable<T>) -> Bool {
    return lhs === rhs
}