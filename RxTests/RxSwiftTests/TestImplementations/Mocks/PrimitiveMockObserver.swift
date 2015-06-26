//
//  PrimitiveMockObserver.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//
//

import Foundation

import RxSwift

class PrimitiveMockObserver<ElementType : Equatable> : ObserverType {
    typealias Element = ElementType
    
    var messages: [Recorded<Element>]
    
    init() {
        self.messages = []
    }
    
    func on(event: Event<Element>) {
        messages.append(Recorded(time: 0, event: event))
    }
}