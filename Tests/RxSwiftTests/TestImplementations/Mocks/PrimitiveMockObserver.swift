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

    private let _events = Synchronized([Recorded<Event<Element>>]())

    var events: [Recorded<Event<Element>>] {
        return self._events.value
    }
    
    func on(_ event: Event<Element>) {
        self._events.mutate { $0.append(Recorded(time: 0, value: event)) }
    }
}
