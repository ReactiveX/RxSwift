//
//  BackgroundThreadPrimitiveHotObservable.swift
//  Tests
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import RxSwift
import XCTest
import Dispatch

final class BackgroundThreadPrimitiveHotObservable<Element: Equatable> : PrimitiveHotObservable<Element> {
    override func subscribe<O : ObserverType>(_ observer: O) -> Disposable where O.Element == Element {
        XCTAssertTrue(!DispatchQueue.isMain)
        return super.subscribe(observer)
    }
}
