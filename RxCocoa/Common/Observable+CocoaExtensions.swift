//
//  Observable+Extensions.swift
//  Rx
//
//  Created by Krunoslav Zaher on 8/29/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif

extension ObservableType {
    
    public func bindTo<O: ObserverType where O.E == E>(target: O) -> Disposable {
        return self.subscribe(target)
    }
    
    public func bindTo<R>(binder: Self -> R) -> R {
        return binder(self)
    }

    public func bindTo<R1, R2>(binder: Self -> R1 -> R2, curriedArgument: R1) -> R2 {
         return binder(self)(curriedArgument)
    }
    
}