//
//  PrimitiveMockObserver.swift
//  Tests
//
//  Created by Krunoslav Zaher on 6/4/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest

final class PrimitiveMockObserver<ElementType> : ObserverType {
    typealias Element = ElementType
    
    var events: [Recorded<Event<Element>>]
    
    init() {
        self.events = []
    }
    
    func on(_ event: Event<Element>) {
        events.append(Recorded(time: 0, value: event))
    }
}
