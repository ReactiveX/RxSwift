//
//  NSObject+Rx+RawRepresentable.swift
//  Rx
//
//  Created by Krunoslav Zaher on 11/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
    import RxSwift
#endif

extension NSObject {
    /**
     Specialization of generic `rx_observe` method.

     This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.
     
     It is useful for observing bridged ObjC enum values.

     For more information take a look at `rx_observe` method.
     */
    @warn_unused_result(message="http://git.io/rxs.uo")
    public func rx_observe<E: RawRepresentable where E.RawValue: KVORepresentable>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<E?> {
        return rx_observe(E.RawValue.KVOType.self, keyPath, options: options, retainSelf: retainSelf)
            .map(E.init)
    }
}

#if !DISABLE_SWIZZLING

    // rx_observeWeakly + RawRepresentable
    extension NSObject {

        /**
         Specialization of generic `rx_observeWeakly` method.

         This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.
     
         It is useful for observing bridged ObjC enum values.

         For more information take a look at `rx_observeWeakly` method.
         */
        @warn_unused_result(message="http://git.io/rxs.uo")
        public func rx_observeWeakly<E: RawRepresentable where E.RawValue: KVORepresentable>(type: E.Type, _ keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<E?> {
            return rx_observeWeakly(E.RawValue.KVOType.self, keyPath, options: options)
                .map(E.init)
        }
    }
#endif
