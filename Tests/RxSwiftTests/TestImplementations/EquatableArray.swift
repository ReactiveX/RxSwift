//
//  EquatableArray.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/15/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

struct EquatableArray<Element: Equatable> : Equatable {
    let elements: [Element]
    init(_ elements: [Element]) {
        self.elements = elements
    }
}

func ==<E>(lhs: EquatableArray<E>, rhs: EquatableArray<E>) -> Bool {
    return lhs.elements == rhs.elements
}

