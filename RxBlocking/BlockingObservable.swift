//
//  BlockingObservable.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 10/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
import RxSwift

/**
`BlockingObservable` is a variety of `Observable` that provides blocking operators. 

It can be useful for testing and demo purposes, but is generally inappropriate for production applications.

If you think you need to use a `BlockingObservable` this is usually a sign that you should rethink your
design.
*/
public struct BlockingObservable<Element> {
    let timeout: TimeInterval?
    let source: Observable<Element>
}
