//
//  DeallocObservable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 12/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

class DeallocObservable {
    let _subject = ReplaySubject<Void>.create(bufferSize:1)

    init() {
    }

    deinit {
        _subject.on(.next(()))
        _subject.on(.completed)
    }
}
