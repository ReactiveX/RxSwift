//
//  Just.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/30/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class Just<Element> : Producer<Element> {
    let element: Element
    
    init(element: Element) {
        self.element = element
    }
    
    override func run<O : ObserverType where O.E == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        observer.on(.Next(element))
        observer.on(.Completed)
        return NopDisposable.instance
    }
}