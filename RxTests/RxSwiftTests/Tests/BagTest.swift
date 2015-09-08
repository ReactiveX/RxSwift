//
//  BagTest.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 8/23/15.
//
//

import Foundation
import XCTest
import RxSwift

class BagTest : RxTest {
}

extension BagTest {
    typealias DoSomething = () -> Void
    typealias KeyType = Bag<DoSomething>.KeyType
    
    func numberOfActionsAfter(nInsertions: Int, deletionsFromStart: Int) {
        var increment = 0
        
        var bag = Bag<DoSomething>()
        
        var keys = [KeyType]()
        
        for _ in 0 ..< nInsertions {
            keys.append(bag.insert({
                increment++
            }))
        }
        
        for i in 0 ..< deletionsFromStart {
            let key = keys[i]
            bag.removeKey(key)
        }
        
        bag.forEach { $0() }
        
        XCTAssertTrue(increment == nInsertions - deletionsFromStart)
    }
    
    func testBag_deletionsFromStart() {
        for i in 0 ..< 50 {
            for j in 0 ... i {
                numberOfActionsAfter(i, deletionsFromStart: j)
            }
        }
    }

    func numberOfActionsAfter(nInsertions: Int, deletionsFromEnd: Int) {
        var increment = 0
        
        var bag = Bag<DoSomething>()
        
        var keys = [KeyType]()
        
        for _ in 0 ..< nInsertions {
            keys.append(bag.insert({
                increment++
            }))
        }
        
        for i in 0 ..< deletionsFromEnd {
            let key = keys[keys.count - 1 - i]
            bag.removeKey(key)
        }
        
        bag.forEach { $0() }
        
        XCTAssertTrue(increment == nInsertions - deletionsFromEnd)
    }

    func testBag_deletionsFromEnd() {
        for i in 0 ..< 50 {
            for j in 0 ... i {
                numberOfActionsAfter(i, deletionsFromEnd: j)
            }
        }
    }
    
    func testBag_immutableForeach() {
        var increment = 0
        
        var bag = Bag<DoSomething>()
        
        var keys = [KeyType]()
        
        for _ in 0 ..< 10 {
            keys.append(bag.insert({
                increment++
            }))
        }
        
        for _ in 0 ..< 2 {
            var j = 0
            bag.forEach { c in
                j++
                if j == 5 {
                    bag.removeAll()
                }
                c()
            }
        }
        
        XCTAssertTrue(increment == 10)
    }
}