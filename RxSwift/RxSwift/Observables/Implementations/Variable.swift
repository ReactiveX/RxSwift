//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Variables can be useful when interacting with imperative 
public class Variable<Element>: ReplaySubject<Element> {
    typealias VariableState = Element
    
    public init(_ firstElement: Element) {
        super.init(firstElement: firstElement)
    }
    
    public init() {
        super.init(bufferSize: 1)
    }
    
    public func next(value: Element) {
        on(.Next(Box(value)))
    }
}

public func << <E>(variable: Variable<E>, element: E) {
    variable.on(.Next(Box(element)))
}