//
//  QueueTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

class QueueTest : RxTest {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
}

extension QueueTest {
    func test() {
        var queue: Queue<Int> = Queue(capacity: 2)
        
        XCTAssertEqual(queue.count, 0)
        
        for i in 100 ..< 200 {
            queue.enqueue(i)
            
            let allElements = Array(queue)
            let correct = Array(100 ... i)
            
            XCTAssertEqual(allElements, correct)
            XCTAssertEqual(queue.peek(), 100)
            XCTAssertEqual(queue.count, i - 100 + 1)
        }
        
        for i in 100 ..< 200 {
            let allElements2 = Array(queue)
            let correct2 = Array(i ... 199)
            
            XCTAssertEqual(allElements2, correct2)
            XCTAssertEqual(queue.dequeue(), i)
            XCTAssertEqual(queue.count, 200 - i - 1)
        }
    }
    
    func testComplexity() {
        var queue: Queue<Int> = Queue(capacity: 2)
        
        XCTAssertEqual(queue.count, 0)
        
        for i in 0 ..< 200000 {
            queue.enqueue(i)
        }
        
        XCTAssertEqual(Array(0 ..< 200000), Array(queue))
    }
}