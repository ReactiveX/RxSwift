//
//  OptionalType.swift
//  Rx
//
//  Created by Tomasz Pikć on 17/04/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

protocol OptionalType {
    associatedtype T
    func intoOptional() -> T?
}

extension Optional: OptionalType {
    func intoOptional() -> Wrapped? {
        return self.flatMap { $0 }
    }
}