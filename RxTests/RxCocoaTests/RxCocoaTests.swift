//
//  RxCocoaTests.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 7/6/15.
//
//

import Foundation
import XCTest
import RxSwift
import RxCocoa

class RxCocoaTest : RxTest {
#if !RELEASE
    func testRxError() {
        let result = _rxError(RxCocoaError.NetworkError, message: "my bad", userInfo: ["a": 1])
        
        let dUserInfo = NSDictionary(dictionary: result.userInfo)
        XCTAssertTrue(dUserInfo.isEqualToDictionary([NSLocalizedDescriptionKey: "my bad", "a" : 1]))
    }
#endif
}