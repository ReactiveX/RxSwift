//
//  QueueTests.swift
//  Rx
//
//  Created by Krunoslav Zaher on 3/21/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import Rx
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
        
        for var i = 100; i < 200; ++i {
            queue.enqueue(i)
            
            XCTAssertEqual(queue.peek(), 100)
            XCTAssertEqual(queue.count, i - 100 + 1)
        }
        
        for var i = 100; i < 200; ++i {
            XCTAssertEqual(queue.dequeue(), i)
            XCTAssertEqual(queue.count, 200 - i - 1)
        }
    }
}