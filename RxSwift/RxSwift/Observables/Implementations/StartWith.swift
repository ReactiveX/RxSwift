//
//  StartWith.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 4/6/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

class StartWith<Element>: Producer<Element> {
    let element: Element
    let source: Observable<Element>
    
    init(source: Observable<Element>, element: Element) {
        self.source = source
        self.element = element
        super.init()
    }
    
    override func subscribe<O : ObserverType where O.Element == Element>(observer: O) -> Disposable {
        observer.on(.Next(Box(element)))
        
        return source.subscribe(observer)
    }
}