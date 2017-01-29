//
//  Resources.swift
//  RxBlocking
//
//  Created by Krunoslav Zaher on 1/21/17.
//  Copyright © 2017 Krunoslav Zaher. All rights reserved.
//

import RxSwift

#if TRACE_RESOURCES
    struct Resources {
        static func incrementTotal() -> Int32 {
            return RxSwift.Resources.incrementTotal()
        }

        static func decrementTotal() -> Int32 {
            return RxSwift.Resources.decrementTotal()
        }

        static var numberOfSerialDispatchQueueObservables: Int32 {
            return RxSwift.Resources.numberOfSerialDispatchQueueObservables
        }

        static var numberOfMapOperators: Int32 {
            return RxSwift.Resources.numberOfMapOperators
        }

        static var total: Int32 {
            return RxSwift.Resources.total
        }
    }
#endif
