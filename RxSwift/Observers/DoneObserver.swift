//
//  DoneObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DoneObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    //static let Instance = DoneObserver<ValueType, ErrorType>()
    
    func on(event: Event<Element>) {
    }
}