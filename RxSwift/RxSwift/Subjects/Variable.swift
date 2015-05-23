//
//  Variable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/28/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

// Variables can be useful when interacting with imperative 
public class Variable<Element>: BehaviorSubject<Element> {
    typealias VariableState = Element
    
    public init(_ value: Element) {
        super.init(value: value)
    }
    
    public func next(value: Element) {
        sendNext(self, value)
    }
}


@availability(*, deprecated=1.4, message="Please use variable.next, it's more clear")
public func << <E>(variable: Variable<E>, element: E) {
    variable.next(element)
}