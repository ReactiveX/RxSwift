//
//  ControlEvent+Driver.swift
//  Rx
//
//  Created by Krunoslav Zaher on 9/19/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
    
extension ControlEvent {
    /**
    Converts `ControlEvent` to `Driver` unit.
    
    `ControlEvent` already can't fail, so no special case needs to be handled.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func asDriver() -> Driver<E> {
        return self.asDriver { (error) -> Driver<E> in
            #if DEBUG
                rxFatalError("Somehow driver received error from a source that shouldn't fail.")
            #else
                return Driver.empty()
            #endif
        }
    }
}