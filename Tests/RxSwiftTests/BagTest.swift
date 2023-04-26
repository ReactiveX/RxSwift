//
//  BagTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 8/23/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

// testable import doesn't work well in Linux
#if !os(Linux)
import XCTest
@testable import RxSwift

final class BagTest : RxTest {
    override var accumulateStatistics: Bool {
        false
    }
}

extension BagTest {
    typealias DoSomething = () -> Void
    typealias KeyType = Bag<DoSomething>.KeyType
    
    func numberOfActionsAfter<T>(_ nInsertions: Int, deletionsFromStart: Int, createNew: () -> T, bagAction: (RxMutableBox<Bag<T>>) -> Void) {
        let bag = RxMutableBox(Bag<T>())
        
        var keys = [KeyType]()
        
        for _ in 0 ..< nInsertions {
            keys.append(bag.value.insert(createNew()))
        }
        
        for i in 0 ..< deletionsFromStart {
            let key = keys[i]
            XCTAssertTrue(bag.value.removeKey(key) != nil)
        }

        bagAction(bag)
    }
    
    func testBag_deletionsFromStart() {
        for i in 0 ..< 50 {
            for j in 0 ... i {
                var numberForEachActions = 0
                var numberObservers = 0
                var numberDisposables = 0

                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> DoSomething in { () -> Void in numberForEachActions += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<DoSomething>>) in bag.value.forEach { $0() }; XCTAssertTrue(bag.value.count == i - j) }
                )
                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> (Event<Int>) -> Void in { _ in numberObservers += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<(Event<Int>) -> Void>>) in dispatch(bag.value, .next(1)); XCTAssertTrue(bag.value.count == i - j) }
                )
                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> Disposable in Disposables.create { numberDisposables += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<Disposable>>) in disposeAll(in: bag.value); XCTAssertTrue(bag.value.count == i - j) }
                )

                XCTAssertTrue(numberForEachActions == i - j)
                XCTAssertTrue(numberObservers == i - j)
                XCTAssertTrue(numberDisposables == i - j)
            }
        }
    }

    func numberOfActionsAfter<T>(_ nInsertions: Int, deletionsFromEnd: Int, createNew: () -> T, bagAction: (RxMutableBox<Bag<T>>) -> Void) {
        let bag = RxMutableBox(Bag<T>())
        
        var keys = [KeyType]()
        
        for _ in 0 ..< nInsertions {
            keys.append(bag.value.insert(createNew()))
        }
        
        for i in 0 ..< deletionsFromEnd {
            let key = keys[keys.count - 1 - i]
            XCTAssertTrue(bag.value.removeKey(key) != nil)
        }

        bagAction(bag)
    }

    func testBag_deletionsFromEnd() {
        for i in 0 ..< 30 {
            for j in 0 ... i {
                var numberForEachActions = 0
                var numberObservers = 0
                var numberDisposables = 0

                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> DoSomething in { () -> Void in numberForEachActions += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<DoSomething>>) in bag.value.forEach { $0() }; XCTAssertTrue(bag.value.count == i - j) }
                )
                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> (Event<Int>) -> Void in { _ in numberObservers += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<(Event<Int>) -> Void>>) in dispatch(bag.value, .next(1)); XCTAssertTrue(bag.value.count == i - j) }
                )
                numberOfActionsAfter(i,
                    deletionsFromStart: j,
                    createNew: { () -> Disposable in Disposables.create { numberDisposables += 1 } },
                    bagAction: { (bag: RxMutableBox<Bag<Disposable>>) in disposeAll(in: bag.value); XCTAssertTrue(bag.value.count == i - j) }
                )

                XCTAssertTrue(numberForEachActions == i - j)
                XCTAssertTrue(numberObservers == i - j)
                XCTAssertTrue(numberDisposables == i - j)
            }
        }
    }
    
    func testBag_immutableForeach() {
//        for breakAt in 0 ..< 50 {
//            var increment1 = 0
//            var increment2 = 0
//            var increment3 = 0
//
//            let bag1 = RxMutableBox(Bag<DoSomething>())
//            let bag2 = RxMutableBox(Bag<(Event<Int>) -> Void>())
//            let bag3 = RxMutableBox(Bag<Disposable>())
//
//            for _ in 0 ..< 50 {
//                _ = bag1.value.insert({
//                    if increment1 == breakAt {
//                        bag1.value.removeAll()
//                    }
//                    increment1 += 1
//                })
//                _ = bag2.value.insert({ _ in
//                    if increment2 == breakAt {
//                        bag2.value.removeAll()
//                    }
//                    increment2 += 1
//                })
//                _ = bag3.value.insert(Disposables.create {
//                    if increment3 == breakAt {
//                        bag3.value.removeAll()
//                    }
//                    increment3 += 1
//                })
//            }
//
//            for _ in 0 ..< 2 {
//                bag1.value.forEach { c in
//                    c()
//                }
//
//                dispatch(bag2.value, .next(1))
//
//                disposeAll(in: bag3.value)
//            }
//
//            XCTAssertEqual(increment1, 50)
//        }
    }

    func testBag_removeAll() {
        var numberForEachActions = 0
        var numberObservers = 0
        var numberDisposables = 0

        numberOfActionsAfter(100,
            deletionsFromStart: 0,
            createNew: { () -> DoSomething in { () -> Void in numberForEachActions += 1 } },
            bagAction: { (bag: RxMutableBox<Bag<DoSomething>>) in bag.value.removeAll(); bag.value.forEach { $0() } }
        )
        numberOfActionsAfter(100,
            deletionsFromStart: 0,
            createNew: { () -> (Event<Int>) -> Void in { _ in numberObservers += 1 } },
            bagAction: { (bag: RxMutableBox<Bag<(Event<Int>) -> Void>>) in bag.value.removeAll(); dispatch(bag.value, .next(1)); }
        )
        numberOfActionsAfter(100,
            deletionsFromStart: 0,
            createNew: { () -> Disposable in Disposables.create { numberDisposables += 1 } },
            bagAction: { (bag: RxMutableBox<Bag<Disposable>>) in bag.value.removeAll(); disposeAll(in: bag.value); }
        )

        XCTAssertTrue(numberForEachActions == 0)
        XCTAssertTrue(numberObservers == 0)
        XCTAssertTrue(numberDisposables == 0)
    }

    func testBag_complexityTestFromFront() {
        var bag = Bag<Disposable>()

        let limit = 10000

        var increment = 0

        var keys: [Bag<Disposable>.KeyType] = []
        for _ in 0..<limit {
            keys.append(bag.insert(Disposables.create { increment += 1 }))
        }

        for i in 0..<limit {
            _ = bag.removeKey(keys[i])
        }
    }

    func testBag_complexityTestFromEnd() {
        var bag = Bag<Disposable>()

        let limit = 10000

        var increment = 0

        var keys: [Bag<Disposable>.KeyType] = []
        for _ in 0..<limit {
            keys.append(bag.insert(Disposables.create { increment += 1 }))
        }

        for i in 0..<limit {
            _ = bag.removeKey(keys[limit - 1 - i])
        }
    }
}
#endif
