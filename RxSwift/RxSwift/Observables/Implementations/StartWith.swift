//
//  StartWith.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation

class StartWith<Element>: Producer<Element> {
    let element: Element
    let source: Observable<Element>
    
    init(source: Observable<Element>, element: Element) {
        self.source = source
        self.element = element
        super.init()
    }
    
    override func run<O : ObserverType where O.Element == Element>(observer: O, cancel: Disposable, setSink: (Disposable) -> Void) -> Disposable {
        sendNext(observer, element)
        
        return source.subscribeSafe(observer)
    }
}