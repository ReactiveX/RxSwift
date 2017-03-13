//
//  PrimitiveSequence+DebugTest.swift
//  Rx
//
//  Created by muukii on 3/13/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class PrimitiveSequenceDebugTest : RxTest {

}

// MARK: debug
extension PrimitiveSequenceDebugTest {
  func testDebug_Completed() {
    let scheduler = TestScheduler(initialClock: 0)

    let xs = scheduler.createHotObservable([
      next(210, 0),
      completed(600)
      ])

    let res = scheduler.start { () -> Observable<Int> in
      return xs.asSingle().debug()
    }

    XCTAssertEqual(res.events, [
      next(600, 0),
      completed(600)
      ])

    XCTAssertEqual(xs.subscriptions, [
      Subscription(200, 600)
      ])
  }

  func testDebug_Error() {
    let scheduler = TestScheduler(initialClock: 0)

    let xs = scheduler.createHotObservable([
      next(210, 0),
      error(600, testError)
      ])

    let res = scheduler.start { () -> Observable<Int> in
      return xs.asSingle().debug()
    }

    XCTAssertEqual(res.events, [
      error(600, testError)
      ])

    XCTAssertEqual(xs.subscriptions, [
      Subscription(200, 600)
      ])
  }

  #if TRACE_RESOURCES
  func testReplayNReleasesResourcesOnComplete() {
    _ = Observable<Int>.just(1).asSingle().debug().subscribe()
  }

  func testReplayNReleasesResourcesOnError() {
    _ = Observable<Int>.error(testError).asSingle().debug().subscribe()
  }
  #endif
}
