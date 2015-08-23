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

#if arch(x86_64) || arch(arm64)
let CGRectType = "{CGRect={CGPoint=dd}{CGSize=dd}}"
let CGSizeType = "{CGSize=dd}"
let CGPointType = "{CGPoint=dd}"
#elseif arch(i386) || arch(arm)
let CGRectType = "{CGRect={CGPoint=ff}{CGSize=ff}}"
let CGSizeType = "{CGSize=ff}"
let CGPointType = "{CGPoint=ff}"
#endif

// rx_observe + CoreGraphics
extension NSObject {
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial), retainSelf: Bool = true) -> Observable<CGRect?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGRectType) != 0 {
                        return nil
                    }
                    var typedValue = CGRect(x: 0, y: 0, width: 0, height: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
            }
    }
    
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial), retainSelf: Bool = true) -> Observable<CGSize?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGSizeType) != 0 {
                        return nil
                    }
                    var typedValue = CGSize(width: 0, height: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
            }
    }
    
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial), retainSelf: Bool = true) -> Observable<CGPoint?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGPointType) != 0 {
                        return nil
                    }
                    var typedValue = CGPoint(x: 0, y: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
            }
    }
}

#if !DISABLE_SWIZZLING

// rx_observeWeakly + CoreGraphics
extension NSObject {
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial)) -> Observable<CGRect?> {
        return rx_observeWeakly(keyPath, options: options)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGRectType) != 0 {
                        return nil
                    }
                    var typedValue = CGRect(x: 0, y: 0, width: 0, height: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
        }
    }
    
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial)) -> Observable<CGSize?> {
        return rx_observeWeakly(keyPath, options: options)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGSizeType) != 0 {
                        return nil
                    }
                    var typedValue = CGSize(width: 0, height: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
        }
    }
    
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New.union(NSKeyValueObservingOptions.Initial)) -> Observable<CGPoint?> {
        return rx_observeWeakly(keyPath, options: options)
            .map { (value: NSValue?) in
                if let value = value {
                    if strcmp(value.objCType, CGPointType) != 0 {
                        return nil
                    }
                    var typedValue = CGPoint(x: 0, y: 0)
                    value.getValue(&typedValue)
                    return typedValue
                }
                else {
                    return nil
                }
        }
    }
}

#endif
