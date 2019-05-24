//
//  BehaviorRelay+CollectionTests.swift
//  RxRelay
//
//  Created by Cristiano Maria Coppotelli on 24/05/2019.
//  Copyright © 2019 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import RxTest
import XCTest

class BehaviorRelayCollectionTests: RxTest {}

extension BehaviorRelayCollectionTests {
    
    func testAcceptUpdatingAtIndex() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        let indexToUpdate = 0
        let updatedValue = 32
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptUpdating(at: indexToUpdate, with: updatedValue)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
        XCTAssert(relay.value[indexToUpdate] == updatedValue)
    }
    
    func testAcceptAppendingElement() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptAppending(32)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
    }
    
    func testAcceptAppendingElements() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptAppending(contentsOf: [32, 22])
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
    }
    
    func testAcceptUpdatingValue() {
        let relay = BehaviorRelay(value: [1: 1, 2: 2, 3: 3])
        var firstRecorded = [Recorded<Event<[Int: Int]>>]()
        var secondRecorded = [Recorded<Event<[Int: Int]>>]()
        let key = 1
        let updatedValue = 32
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptUpdating(value: updatedValue, forKey: key)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
        XCTAssert(relay.value[key] == updatedValue)
    }
    
    func testAcceptRemovingAtIndex() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        let indexToRemove = 1
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptRemoving(at: indexToRemove)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
    }
    
    func testAcceptRemovingAtIndexes() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        let indexesToRemove = [0,1]
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptRemoving(at: indexesToRemove)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
    }
    
    func testAcceptRemovingWithPredicate() {
        let relay = BehaviorRelay(value: [1,2,3,4,5])
        let predicate: ((Int) throws -> Bool ) = { value in
            return relay.value.first(where: { $0 == value }) == value
        }
        var firstRecorded = [Recorded<Event<[Int]>>]()
        var secondRecorded = [Recorded<Event<[Int]>>]()
        relay.accept(relay.value)
        _ = relay.subscribe { event in
            firstRecorded.append(Recorded(time: 0, value: event))
        }
        relay.acceptRemoving(where: predicate)
        _ = relay.subscribe { event in
            secondRecorded.append(Recorded(time: 0, value: event))
        }
        XCTAssertNotEqual(firstRecorded, secondRecorded)
    }
}
