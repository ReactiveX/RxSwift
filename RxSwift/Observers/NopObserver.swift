//
//  NopObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class NopObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    init() {
        
    }
    
    func on(event: Event<Element>) {
    }
}