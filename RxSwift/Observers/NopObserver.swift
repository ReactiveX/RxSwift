//
//  NopObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

public class NopObserver<ElementType> : ObserverType {
    public typealias Element = ElementType
    
    public init() {
        
    }
    
    public func on(event: Event<Element>) {
    }
}