//
//  XCTest+Rx.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

struct EquatableArray<Element: Equatable> : Equatable {
    let elements: [Element]
    init(_ elements: [Element]) {
        self.elements = elements
    }
}

func == <E: Equatable>(lhs: EquatableArray<E>, rhs: EquatableArray<E>) -> Bool {
    return lhs.elements == rhs.elements
}

public func XCTAssertEqual<T: Equatable>(lhs: [Recorded<T>], _ rhs: [Recorded<T>], file: String = __FILE__, line: Int = __LINE__) {
    let leftEquatable = lhs.map { AnyEquatable(target: $0, comparer: ==) }
    let rightEquatable = rhs.map { AnyEquatable(target: $0, comparer: ==) }
    if leftEquatable != rightEquatable {
        fatalError("\(file):\(line)\n\(leftEquatable)\n is not equal to\n\(rightEquatable)")
    }
    //XCFail()
}