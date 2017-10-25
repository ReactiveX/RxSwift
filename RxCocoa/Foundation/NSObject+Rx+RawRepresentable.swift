//
//  NSObject+Rx+RawRepresentable.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 11/9/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//

#if !os(Linux)

import Foundation.NSObject
#if !RX_NO_MODULE
    import RxSwift
#endif

extension Reactive where Base: NSObject {
    /**
     Specialization of generic `observe` method.

     This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.
     
     It is useful for observing bridged ObjC enum values.

     For more information take a look at `observe` method.
     */
    public func observe<E: RawRepresentable>(_ type: E.Type, _ keyPath: String, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<E?> where E.RawValue: KVORepresentable {
        return observe(E.RawValue.KVOType.self, keyPath, options: options, retainSelf: retainSelf)
            .map(E.init)
    }

    /**
     Specialization of generic `observe` method.

     This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.

     It is useful for observing bridged ObjC enum values.

     For more information take a look at `observe` method.
     */
    @available(swift 4.0)
    public func observe<E: RawRepresentable>(_ keyPath: KeyPath<Base, E>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<E> where E.RawValue: KVORepresentable {
        return observe(E.self, keyPath.kvcKeyPathString, options: options, retainSelf: retainSelf).flatMap { value -> Observable<E> in
            guard let value  = value else {
                #if DEBUG
                    rxFatalError("Something went wrong with KVO observing mechanism")
                #else
                    return Observable.empty()
                #endif
            }
            return Observable.just(value)
        }
    }

    /**
     Specialization of generic `observe` method.

     This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.

     It is useful for observing bridged ObjC enum values.

     For more information take a look at `observe` method.
     */
    @available(swift 4.0)
    public func observe<E: RawRepresentable>(_ keyPath: KeyPath<Base, E?>, options: KeyValueObservingOptions = [.new, .initial], retainSelf: Bool = true) -> Observable<E?> where E.RawValue: KVORepresentable {
        return observe(E.self, keyPath.kvcKeyPathString, options: options, retainSelf: retainSelf)
    }
}

#if !DISABLE_SWIZZLING

    // observeWeakly + RawRepresentable
    extension Reactive where Base: NSObject {

        /**
         Specialization of generic `observeWeakly` method.

         This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.
     
         It is useful for observing bridged ObjC enum values.

         For more information take a look at `observeWeakly` method.
         */
        public func observeWeakly<E: RawRepresentable>(_ type: E.Type, _ keyPath: String, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<E?> where E.RawValue: KVORepresentable {
            return observeWeakly(E.RawValue.KVOType.self, keyPath, options: options)
                .map(E.init)
        }

        /**
         Specialization of generic `observeWeakly` method.

         This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.

         It is useful for observing bridged ObjC enum values.

         For more information take a look at `observeWeakly` method.
         */
        @available(swift 4.0)
        public func observeWeakly<E: RawRepresentable>(_ keyPath: KeyPath<Base, E>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<E?> where E.RawValue: KVORepresentable {
            return observeWeakly(E.self, keyPath.kvcKeyPathString, options: options)
        }

        /**
         Specialization of generic `observeWeakly` method.

         This specialization first observes `KVORepresentable` value and then converts it to `RawRepresentable` value.

         It is useful for observing bridged ObjC enum values.

         For more information take a look at `observeWeakly` method.
         */
        @available(swift 4.0)
        public func observeWeakly<E: RawRepresentable>(_ keyPath: KeyPath<Base, E?>, options: KeyValueObservingOptions = [.new, .initial]) -> Observable<E?> where E.RawValue: KVORepresentable {
            return observeWeakly(E.self, keyPath.kvcKeyPathString, options: options)
        }
    }
#endif

#endif
