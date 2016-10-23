//
//  ObservableConvertibleType+Blocking.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 7/12/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableConvertibleType {
    /// Converts an Observable into a `BlockingObservable` (an Observable with blocking operators).
    ///
    /// - parameter timeout: Maximal time interval BlockingObservable can block without throwing `RxError.timeout`.
    /// - returns: `BlockingObservable` version of `self`
    public func toBlocking(timeout: RxTimeInterval? = nil) -> BlockingObservable<E> {
        return BlockingObservable(timeout: timeout, source: self.asObservable())
    }
}
