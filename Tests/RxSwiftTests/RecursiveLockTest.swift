//
//  RecursiveLockTest.swift
//  Tests
//
//  Created by Krunoslav Zaher on 1/22/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest

#if os(Linux)
    import Glibc
    import Foundation
#else
    import Darwin
#endif

private class StrandClosure {
    let closure: () -> Void

    init(closure: @escaping () -> Void) {
      self.closure = closure
    }
}

#if os(Linux)
    private func runner(arg: UnsafeMutableRawPointer?) -> UnsafeMutableRawPointer? {
        guard let arg = arg else { return nil }
        let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
        unmanaged.takeUnretainedValue().closure()
        unmanaged.release()
        return nil
    }
#else
    private func runner(arg: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer? {
        let unmanaged = Unmanaged<StrandClosure>.fromOpaque(arg)
        unmanaged.takeUnretainedValue().closure()
        unmanaged.release()
        return nil
    }
#endif

class RecursiveLockTests: RxTest {
    var joinPthreads = Synchronized([pthread_t]())

    override func tearDown() {
      super.tearDown()

      for thread in joinPthreads.value {
        pthread_join(thread, nil)
      }
    }

    // code taken from https://github.com/ketzusaka/Strand/blob/master/Sources/Strand.swift

    func thread(action: @escaping () -> ()) {
        let holder = Unmanaged.passRetained(StrandClosure(closure: action))
        let pointer = UnsafeMutableRawPointer(holder.toOpaque())
        #if os(Linux)
            var pthread: pthread_t = 0
            guard pthread_create(&pthread, nil, runner, pointer) == 0 else {
                holder.release()
                fatalError("Something went wrong")
            }
        #else
            var maybePthread: pthread_t?
            guard pthread_create(&maybePthread, nil, runner, pointer) == 0,
              let pthread = maybePthread else {
                holder.release()
                fatalError("Something went wrong")
            }
        #endif

        self.joinPthreads.mutate { $0.append(pthread) }
    }
}

private protocol Lock {
    func lock()
    func unlock()
}

extension RecursiveLock: Lock {

}

private struct NoLock: Lock {
    func lock() {

    }

    func unlock() {

    }
}

extension RecursiveLockTests {
    func testSynchronizes() {
        func performTestLock(lock: Lock, expectedValues: [Int]) {
            let values = Synchronized([Int]())

            let expectation1 = self.expectation(description: "first finishes")
            let expectation2 = self.expectation(description: "second finishes")

            self.thread {
                lock.lock()
                self.thread {
                    lock.lock()
                    values.mutate { $0.append(2) }
                    lock.unlock()

                    expectation2.fulfill()
                }
                Thread.sleep(forTimeInterval: 0.3)
                values.mutate { $0.append(1) }
                lock.unlock()

                expectation1.fulfill()
            }

            waitForExpectations(timeout: 2.0) { e in
                XCTAssertNil(e)
            }

            XCTAssertEqual(values.value, expectedValues)
        }

        performTestLock(lock: RecursiveLock(), expectedValues: [1, 2])
        performTestLock(lock: NoLock(), expectedValues: [2, 1])
    }

    func testIsReentrant() {
        let recursiveLock = RecursiveLock()

        recursiveLock.lock()
        recursiveLock.lock()
        recursiveLock.unlock()
        recursiveLock.unlock()
    }

    #if TRACE_RESOURCES
        func testLockUnlockCountsResources() {
            let lock = RecursiveLock()

            let initial = Resources.total

            lock.lock()

            XCTAssertEqual((initial + 1) as Int32, Resources.total)

            lock.unlock()

            XCTAssertEqual(initial, Resources.total)
        }
    #endif
}
