//
//  VariableType.swift
//  Rx
//
//  Created by Ilya Laryionau on 20/05/16.
//  Copyright © 2016 Krunoslav Zaher. All rights reserved.
//

import Foundation

public protocol VariableType {
    associatedtype E

    /// The current value of variable.
    var value: E { get }
}