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

// rx_observe + CoreGraphics
extension NSObject {
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, retainSelf: Bool = true) -> Observable<CGRect?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGRect={CGPoint=dd}{CGSize=dd}}") != 0 && strcmp(value.objCType, "{CGRect={CGPoint=ff}{CGSize=ff}}") != 0 {
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
    
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, retainSelf: Bool = true) -> Observable<CGSize?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGSize=dd}") != 0 && strcmp(value.objCType, "{CGSize=ff}") != 0 {
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
    
    public func rx_observe(keyPath: String, options: NSKeyValueObservingOptions = NSKeyValueObservingOptions.New | NSKeyValueObservingOptions.Initial, retainSelf: Bool = true) -> Observable<CGPoint?> {
        return rx_observe(keyPath, options: options, retainSelf: retainSelf) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGPoint=dd}") != 0 && strcmp(value.objCType, "{CGPoint=ff}") != 0 {
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
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = .New | .Initial) -> Observable<CGRect?> {
        return rx_observeWeakly(keyPath, options: options) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGRect={CGPoint=dd}{CGSize=dd}}") != 0 && strcmp(value.objCType, "{CGRect={CGPoint=ff}{CGSize=ff}}") != 0 {
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
    
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = .New | .Initial) -> Observable<CGSize?> {
        return rx_observeWeakly(keyPath, options: options) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGSize=dd}") != 0 && strcmp(value.objCType, "{CGSize=ff}") != 0 {
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
    
    public func rx_observeWeakly(keyPath: String, options: NSKeyValueObservingOptions = .New | .Initial) -> Observable<CGPoint?> {
        return rx_observeWeakly(keyPath, options: options) as Observable<NSValue?>
            >- map { value in
                if let value = value {
                    if strcmp(value.objCType, "{CGPoint=dd}") != 0 && strcmp(value.objCType, "{CGPoint=ff}") != 0 {
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
