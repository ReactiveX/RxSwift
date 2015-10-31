//
//  Just.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Just<Element> : Producer<Element> {
    private let _element: Element
    
    init(element: Element) {
        _element = element
    }
    
    override func subscribe<O : ObserverType where O.E == Element>(observer: O) -> Disposable {
        observer.on(.Next(_element))
        observer.on(.Completed)
        return NopDisposable.instance
    }
}