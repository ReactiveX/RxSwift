//
//  DisposedObserver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 2/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class DisposedObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    //static let Instance = DisposedObserver<ValueType>()
    
    func on(event: Event<Element>) -> Result<Void> {
        rxFatalError("Already disposed")
        return .Error(UnknownError)
    }
}