//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class Variable<Element>: ReplaySubject<Element> {
    typealias VariableState = Element
    
    public init(_ initialEvent: Event<Element>) {
        super.init(bufferSize: 1)
    }
}

public func << <E>(variable: Variable<E>, element: E) {
    variable.on(.Next(Box(element)))
}