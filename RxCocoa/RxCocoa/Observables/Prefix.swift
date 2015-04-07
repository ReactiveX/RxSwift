//
//  Prefix.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx

class Prefix<Element>: Observable<Element> {
    let element: Element
    let source: Observable<Element>
    
    init(source: Observable<Element>, element: Element) {
        self.source = source
        self.element = element
    }
    
    override func subscribe(observer: ObserverOf<Element>) -> Result<Disposable> {
        let result = observer.on(.Next(Box(element)))
     
        if let error = result.error {
            observer.on(.Error(error))
            return .Error(error)
        }
        
        return source.subscribe(observer)
    }
}