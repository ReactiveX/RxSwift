//
//  PrimitiveMockObserver.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 6/4/15.
//
//

import Foundation
import RxSwift
import RxTests

class PrimitiveMockObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    var events: [Recorded<Event<Element>>]
    
    init() {
        self.events = []
    }
    
    func on(event: Event<Element>) {
        events.append(Recorded(time: 0, event: event))
    }
}