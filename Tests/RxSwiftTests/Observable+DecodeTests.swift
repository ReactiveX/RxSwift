//
//  Observable+DecodeTests.swift
//  Tests
//
//  Created by Shai Mishali on 25/07/2020.
//  Copyright © 2020 Krunoslav Zaher. All rights reserved.
//

import XCTest
import RxSwift
import RxTest

class ObservableDecodeTest: RxTest {
}

extension ObservableDecodeTest {
  func testDecodeValidJSON() {
    let rawJSON = """
    [
      {"id": 1, "name": "Shai", "country": "Israel"},
      {"id": 2, "name": "Kruno"}
    ]
    """.data(using: .utf8)!

    let scheduler = TestScheduler(initialClock: 0)

    let res = scheduler.start {
        Observable
          .just(rawJSON)
          .decode(type: [FakeObject].self, decoder: JSONDecoder())
    }

    XCTAssertEqual(res.events, [
        .next(200, [
          FakeObject(id: 1, name: "Shai", country: "Israel"),
          FakeObject(id: 2, name: "Kruno", country: nil)
        ]),
        .completed(200)
        ])
  }

  func testDecodeInvalidJSON() {
    let rawJSON = """
    [
      {
    ]
    """.data(using: .utf8)!

    let scheduler = TestScheduler(initialClock: 0)

    let res = scheduler.start {
        Observable
          .just(rawJSON)
          .decode(type: [FakeObject].self, decoder: JSONDecoder())
    }

    XCTAssertEqual(res.events.count, 1)
    XCTAssertNotNil(res.events.first?.value.error)
  }
}

private struct FakeObject: Equatable, Decodable {
  let id: Int
  let name: String
  let country: String?
}
