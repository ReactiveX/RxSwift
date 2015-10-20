//
//  BackgroundThreadPrimitiveHotObservable.swift
//  RxTests
//
//  Created by Krunoslav Zaher on 10/19/15.
//
//

import Foundation
import RxSwift
import XCTest

class BackgroundThreadPrimitiveHotObservable<ElementType: Equatable> : PrimitiveHotObservable<ElementType> {
    override func subscribe<O : ObserverType where O.E == E>(observer: O) -> Disposable {
        XCTAssertTrue(!NSThread.isMainThread())
        return super.subscribe(observer)
    }
}