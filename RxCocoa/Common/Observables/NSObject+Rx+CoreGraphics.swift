//
//  NSObject+Rx+CoreGraphics.swift
//  RxCocoa
//
//  Created by Krunoslav Zaher on 7/30/15.
//  Copyright (c) 2015 Krunoslav Zaher. All rights reserved.
//

import Foundation
#if !RX_NO_MODULE
import RxSwift
#endif
import CoreGraphics

// MARK: Deprecated, CGPoint, CGRect, CGSize are now KVORepresentable

extension NSObject {
    /**
    Specialization of generic `rx_observe` method.

    For more information take a look at `rx_observe` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<CGRect?> {
        return rx_observe(NSValue.self, keyPath, options: options, retainSelf: retainSelf)
            .map(CGRect.init)
    }
    
    /**
    Specialization of generic `rx_observe` method.
    
    For more information take a look at `rx_observe` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<CGSize?> {
        return rx_observe(NSValue.self, keyPath, options: options, retainSelf: retainSelf)
            .map(CGSize.init)
    }
    
    /**
    Specialization of generic `rx_observe` method.
    
    For more information take a look at `rx_observe` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial], retainSelf: Bool = true) -> Observable<CGPoint?> {
        return rx_observe(NSValue.self, keyPath, options: options, retainSelf: retainSelf)
            .map(CGPoint.init)
    }
}

#if !DISABLE_SWIZZLING

// rx_observeWeakly + CoreGraphics
extension NSObject {

    /**
    Specialization of generic `rx_observeWeakly` method.
    
    For more information take a look at `rx_observeWeakly` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<CGRect?> {
        return rx_observeWeakly(NSValue.self, keyPath, options: options)
            .map(CGRect.init)
    }
    
    /**
    Specialization of generic `rx_observeWeakly` method.
    
    For more information take a look at `rx_observeWeakly` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<CGSize?> {
        return rx_observeWeakly(NSValue.self, keyPath, options: options)
            .map(CGSize.init)
    }
    
    /**
    Specialization of generic `rx_observeWeakly` method.
    
    For more information take a look at `rx_observeWeakly` method.
    */
    @warn_unused_result(message="http://git.io/rxs.uo")
    @available(*, deprecated=2.0.0, message="Please use version that takes type as first argument.")
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = [.New, .Initial]) -> Observable<CGPoint?> {
        return rx_observeWeakly(NSValue.self, keyPath, options: options)
            .map(CGPoint.init)
    }
}

#endif
