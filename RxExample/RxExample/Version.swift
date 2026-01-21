//
//  Version.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 5/20/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Unique: NSObject {}

struct Version<Value>: Hashable {
    private let _unique: Unique
    let value: Value

    init(_ value: Value) {
        _unique = Unique()
        self.value = value
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(_unique)
    }

    static func == (lhs: Version<Value>, rhs: Version<Value>) -> Bool {
        lhs._unique === rhs._unique
    }
}

extension Version {
    func mutate(transform: (inout Value) -> Void) -> Version<Value> {
        var newSelf = value
        transform(&newSelf)
        return Version(newSelf)
    }

    func mutate(transform: (inout Value) throws -> Void) rethrows -> Version<Value> {
        var newSelf = value
        try transform(&newSelf)
        return Version(newSelf)
    }
}
