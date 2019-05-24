//
//  BehaviorRelay+KeyPathTests.swift
//  Rx
//
//  Created by Cristiano Maria Coppotelli on 24/05/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import XCTest

class BehaviorRelayKeyPathTests: RxTest {}

fileprivate class KeyPathUpdatedReferenced {
    var referencedFromPath: KeyPathUpdatedReferenced = KeyPathUpdatedReferenced()
}

fileprivate struct KeyPathUpdatedValue {
    var referencedFromPath: Int = 0
}

extension BehaviorRelayKeyPathTests {
    
    func acceptUpdatingAtKeyPathReference() {
        let relay = BehaviorRelay(value: KeyPathUpdatedReferenced())
        let updatedValue = KeyPathUpdatedReferenced()
        var firstRecorded = [Recorded<Event<KeyPathUpdatedReferenced>>]()
        var secondRecorded = [Recorded<Event<KeyPathUpdatedReferenced>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptUpdating(atKeyPath: \KeyPathUpdatedReferenced.referencedFromPath, with: updatedValue)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssert(relay.value.referencedFromPath === updatedValue)
    }
    
    func acceptUpdatingAtKeyPathValue() {
        let relay = BehaviorRelay(value: KeyPathUpdatedValue())
        let updatedValue = 100
        var firstRecorded = [Recorded<Event<KeyPathUpdatedValue>>]()
        var secondRecorded = [Recorded<Event<KeyPathUpdatedValue>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptUpdating(atKeyPath: \KeyPathUpdatedValue.referencedFromPath, with: updatedValue)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssert(relay.value.referencedFromPath == updatedValue)
    }
    
}
