//
//  Resources.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 1/21/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if TRACE_RESOURCES
enum Resources {
    static func incrementTotal() -> Int32 {
        RxSwift.Resources.incrementTotal()
    }

    static func decrementTotal() -> Int32 {
        RxSwift.Resources.decrementTotal()
    }

    static var numberOfSerialDispatchQueueObservables: Int32 {
        RxSwift.Resources.numberOfSerialDispatchQueueObservables
    }

    static var total: Int32 {
        RxSwift.Resources.total
    }
}
#endif
