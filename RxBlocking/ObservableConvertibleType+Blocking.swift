//
//  ObservableConvertibleType+Blocking.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

public extension ObservableConvertibleType {
    /// Converts an Observable into a `BlockingObservable` (an Observable with blocking operators).
    ///
    /// - parameter timeout: Maximal time interval BlockingObservable can block without throwing `RxError.timeout`.
    /// - returns: `BlockingObservable` version of `self`
    func toBlocking(timeout: TimeInterval? = nil) -> BlockingObservable<Element> {
        BlockingObservable(timeout: timeout, source: asObservable())
    }
}
