//
//  Event+Equatable.swift
//  RxTest
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/// Compares two events. They are equal if they are both the same member of `Event` enumeration.
///
/// In case `Error` events are being compared, they are equal in case their `NSError` representations are equal (domain and code)
/// and their string representations are equal.
public func == <Element: Equatable>(lhs: Event<Element>, rhs: Event<Element>) -> Bool {
    switch (lhs, rhs) {
    case (.completed, .completed): return true
    case (.error(let e1), .error(let e2)):
        #if os(Linux)
          return  "\(e1)" == "\(e2)"
        #else
          let error1 = e1 as NSError
          let error2 = e2 as NSError

          return error1.domain == error2.domain
              && error1.code == error2.code
              && "\(e1)" == "\(e2)"
        #endif
    case (.next(let v1), .next(let v2)): return v1 == v2
    default: return false
    }
}
