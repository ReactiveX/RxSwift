//
//  DisposeBagTest.swift
//  Tests
//
//  Created by Michael Long on 6/16/18.
//  Copyright © 2018 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class DisposeBagTest : RxTest {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }
}

// DisposeBag insert test
extension DisposeBagTest {
    func testDisposeBagInsert() {
        let disposable1 = TestDisposable()
        let disposable2 = TestDisposable()

        var disposeBag: DisposeBag? = DisposeBag()

        disposeBag?.insert(disposable1)
        disposeBag?.insert(disposable2)

        XCTAssert(disposable1.count == 0)
        XCTAssert(disposable2.count == 0)
        disposeBag = nil
        XCTAssert(disposable1.count == 1)
        XCTAssert(disposable2.count == 1)
    }

}

// DisposeBag bag test
extension DisposeBagTest {
    func testDisposeBagVaradicInsert() {
        let disposable1 = TestDisposable()
        let disposable2 = TestDisposable()

        var disposeBag: DisposeBag? = DisposeBag()

        disposeBag?.insert(disposable1, disposable2)

        XCTAssert(disposable1.count == 0)
        XCTAssert(disposable2.count == 0)
        disposeBag = nil
        XCTAssert(disposable1.count == 1)
        XCTAssert(disposable2.count == 1)
    }

    func testDisposeBagVaradicInsertArray() {
        let disposable1 = TestDisposable()
        let disposable2 = TestDisposable()

        var disposeBag: DisposeBag? = DisposeBag()

        disposeBag?.insert([disposable1, disposable2])

        XCTAssert(disposable1.count == 0)
        XCTAssert(disposable2.count == 0)
        disposeBag = nil
        XCTAssert(disposable1.count == 1)
        XCTAssert(disposable2.count == 1)
    }
}

// DisposeBag function builder initializer tests
extension DisposeBagTest {
    func testDisposableBuilderInitializer() {
        let disposable1 = TestDisposable()
        let disposable2 = TestDisposable()
        let disposable3 = TestDisposable()

        var disposeBag = DisposeBag {
            disposable1
            disposable2
            disposable3
        }

        XCTAssert(disposable1.count == 0)
        XCTAssert(disposable2.count == 0)
        XCTAssert(disposable3.count == 0)
        disposeBag = DisposeBag()
        XCTAssert(disposable1.count == 1)
        XCTAssert(disposable2.count == 1)
        XCTAssert(disposable3.count == 1)

        // Avoids "Variable 'disposeBag' was written to, but never read"
        _ = disposeBag
    }

    func testDisposableBuilderInsert() {
        let disposable1 = TestDisposable()
        let disposable2 = TestDisposable()
        let disposable3 = TestDisposable()
        let disposable4 = TestDisposable()

        var disposeBag = DisposeBag {
            disposable1
            disposable2
        }

        disposeBag.insert {
            disposable3
            disposable4
        }

        XCTAssert(disposable1.count == 0)
        XCTAssert(disposable2.count == 0)
        XCTAssert(disposable3.count == 0)
        XCTAssert(disposable4.count == 0)
        disposeBag = DisposeBag()
        XCTAssert(disposable1.count == 1)
        XCTAssert(disposable2.count == 1)
        XCTAssert(disposable3.count == 1)
        XCTAssert(disposable4.count == 1)

        // Avoids "Variable 'disposeBag' was written to, but never read"
        _ = disposeBag
    }
}

private class TestDisposable: Disposable {
    var count = 0
    func dispose() {
        count += 1
    }
}
